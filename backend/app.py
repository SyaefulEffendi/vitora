from flask import Flask, request, jsonify
from flask_cors import CORS
import pymysql
from werkzeug.security import generate_password_hash, check_password_hash

app = Flask(__name__)
CORS(app)  # Allow frontend to communicate with backend

# Database Configuration
# Using default XAMPP credentials (root, no password)
DB_HOST = '127.0.0.1'
DB_USER = 'root'
DB_PASSWORD = ''
DB_NAME = 'vitora'

def get_db_connection():
    try:
        connection = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
        return connection
    except Exception as e:
        print(f"Error connecting to database: {e}")
        return None

def init_db():
    """Create the users table if it doesn't exist."""
    conn = get_db_connection()
    if conn:
        try:
            with conn.cursor() as cursor:
                # Table users
                create_users_table = """
                CREATE TABLE IF NOT EXISTS users (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    nama VARCHAR(100) NOT NULL,
                    nomor_telepon VARCHAR(20) NOT NULL,
                    email VARCHAR(100) NOT NULL UNIQUE,
                    password_hash VARCHAR(255) NOT NULL,
                    avatar VARCHAR(50) DEFAULT 'default',
                    focus_categories VARCHAR(100) DEFAULT '',
                    points INT DEFAULT 0,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
                """
                cursor.execute(create_users_table)
                
                # Check if we need to add focus_categories to existing users table
                try:
                    cursor.execute("ALTER TABLE users ADD COLUMN focus_categories VARCHAR(100) DEFAULT ''")
                except Exception:
                    pass
                try:
                    cursor.execute("ALTER TABLE users ADD COLUMN points INT DEFAULT 0")
                except Exception:
                    pass

                # Table missions
                create_missions_table = """
                CREATE TABLE IF NOT EXISTS missions (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    title VARCHAR(150) NOT NULL,
                    subtitle VARCHAR(255),
                    category VARCHAR(50) NOT NULL,
                    difficulty VARCHAR(20) NOT NULL,
                    points INT NOT NULL,
                    duration_minutes INT DEFAULT 0,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
                """
                cursor.execute(create_missions_table)

                # Table user_missions
                create_user_missions_table = """
                CREATE TABLE IF NOT EXISTS user_missions (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    user_id INT NOT NULL,
                    mission_id INT NOT NULL,
                    status VARCHAR(20) DEFAULT 'underway',
                    proof_image_path VARCHAR(255),
                    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    completed_at TIMESTAMP NULL,
                    FOREIGN KEY (user_id) REFERENCES users(id),
                    FOREIGN KEY (mission_id) REFERENCES missions(id)
                )
                """
                cursor.execute(create_user_missions_table)

                # Insert dummy missions if empty
                cursor.execute("SELECT COUNT(*) as count FROM missions")
                if cursor.fetchone()['count'] == 0:
                    dummy_missions = [
                        ('Lari Pagi', 'Berlari selama 15 menit', 'Fisik', 'Medium', 20, 15),
                        ('Meditasi', 'Lakukan meditasi selama 5 menit', 'Mental', 'Easy', 10, 5),
                        ('Sapa Tetangga', 'Sapa 3 orang tetangga hari ini', 'Sosial', 'Easy', 10, 0),
                        ('Workout Beban', 'Latihan angkat beban ringan', 'Fisik', 'Hard', 30, 30),
                        ('Jurnal Syukur', 'Tulis 3 hal yang disyukuri', 'Mental', 'Medium', 15, 10),
                        ('Kerja Bakti', 'Ikut kegiatan bersih-bersih lingkungan', 'Sosial', 'Expert', 50, 60),
                    ]
                    insert_mission = "INSERT INTO missions (title, subtitle, category, difficulty, points, duration_minutes) VALUES (%s, %s, %s, %s, %s, %s)"
                    cursor.executemany(insert_mission, dummy_missions)

            conn.commit()
            print("Database initialized successfully.")
        except Exception as e:
            print(f"Error initializing database: {e}")
        finally:
            conn.close()

# Initialize the database when the app starts
init_db()

@app.route('/api/register', methods=['POST'])
def register():
    data = request.get_json()
    
    nama = data.get('nama')
    nomor_telepon = data.get('nomor_telepon')
    email = data.get('email')
    password = data.get('password')
    avatar = data.get('avatar', 'default')

    if not all([nama, nomor_telepon, email, password]):
        return jsonify({'error': 'Semua field wajib diisi (kecuali avatar)'}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        with conn.cursor() as cursor:
            # Check if email already exists
            cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
            if cursor.fetchone():
                return jsonify({'error': 'Email sudah terdaftar'}), 400

            # Hash the password
            hashed_password = generate_password_hash(password)

            # Insert new user
            insert_query = """
            INSERT INTO users (nama, nomor_telepon, email, password_hash, avatar)
            VALUES (%s, %s, %s, %s, %s)
            """
            cursor.execute(insert_query, (nama, nomor_telepon, email, hashed_password, avatar))
        
        conn.commit()
        return jsonify({'message': 'Registrasi berhasil!'}), 201
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@app.route('/api/login', methods=['POST'])
def login():
    data = request.get_json()
    
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({'error': 'Email dan password wajib diisi'}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
            user = cursor.fetchone()

            if user and check_password_hash(user['password_hash'], password):
                # Login successful
                # For a real app, you'd generate a JWT token here. 
                # For now, we just return success and basic user info.
                user_info = {
                    'id': user['id'],
                    'nama': user['nama'],
                    'email': user['email'],
                    'avatar': user['avatar']
                }
                return jsonify({
                    'message': 'Login berhasil',
                    'user': user_info
                }), 200
            else:
                return jsonify({'error': 'Email atau password salah'}), 401

    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@app.route('/api/user/categories', methods=['POST'])
def save_categories():
    data = request.get_json()
    email = data.get('email')
    categories = data.get('categories') # e.g., "Mental,Fisik"
    
    if not email or categories is None:
        return jsonify({'error': 'Email dan categories diperlukan'}), 400
        
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        with conn.cursor() as cursor:
            cursor.execute("UPDATE users SET focus_categories = %s WHERE email = %s", (categories, email))
            if cursor.rowcount == 0:
                return jsonify({'error': 'User tidak ditemukan'}), 404
        conn.commit()
        return jsonify({'message': 'Kategori berhasil disimpan!'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

import os
from werkzeug.utils import secure_filename

UPLOAD_FOLDER = 'uploads/proofs'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/api/missions', methods=['GET'])
def get_missions():
    email = request.args.get('email')
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        with conn.cursor() as cursor:
            # Get user info and focus categories
            if email:
                cursor.execute("SELECT id, focus_categories FROM users WHERE email = %s", (email,))
                user = cursor.fetchone()
                if user:
                    categories = [cat.strip() for cat in user['focus_categories'].split(',') if cat.strip()]
                    if categories:
                        format_strings = ','.join(['%s'] * len(categories))
                        cursor.execute(f"SELECT * FROM missions WHERE category IN ({format_strings})", tuple(categories))
                    else:
                        cursor.execute("SELECT * FROM missions")
                else:
                    cursor.execute("SELECT * FROM missions")
            else:
                cursor.execute("SELECT * FROM missions")
            
            missions = cursor.fetchall()
            return jsonify({'missions': missions}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@app.route('/api/missions/start', methods=['POST'])
def start_mission():
    data = request.get_json()
    email = data.get('email')
    mission_id = data.get('mission_id')

    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        with conn.cursor() as cursor:
            cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
            user = cursor.fetchone()
            if not user:
                return jsonify({'error': 'User tidak ditemukan'}), 404

            # Check if already underway
            cursor.execute("SELECT id FROM user_missions WHERE user_id = %s AND mission_id = %s AND status = 'underway'", (user['id'], mission_id))
            if cursor.fetchone():
                return jsonify({'error': 'Misi sudah berjalan'}), 400

            cursor.execute("INSERT INTO user_missions (user_id, mission_id, status) VALUES (%s, %s, 'underway')", (user['id'], mission_id))
        conn.commit()
        return jsonify({'message': 'Misi dimulai'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@app.route('/api/missions/checkin', methods=['POST'])
def checkin_mission():
    email = request.form.get('email')
    mission_id = request.form.get('mission_id')
    
    if 'proof_image' not in request.files:
        return jsonify({'error': 'Tidak ada foto bukti'}), 400
        
    file = request.files['proof_image']
    if file.filename == '':
        return jsonify({'error': 'Tidak ada file yang dipilih'}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        # Save image
        filename = secure_filename(f"{email}_{mission_id}_{file.filename}")
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)

        with conn.cursor() as cursor:
            cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
            user = cursor.fetchone()
            if not user:
                return jsonify({'error': 'User tidak ditemukan'}), 404

            # Mark mission as completed
            cursor.execute("""
                UPDATE user_missions 
                SET status = 'completed', proof_image_path = %s, completed_at = CURRENT_TIMESTAMP
                WHERE user_id = %s AND mission_id = %s AND status = 'underway'
            """, (file_path, user['id'], mission_id))
            
            if cursor.rowcount == 0:
                return jsonify({'error': 'Misi tidak ditemukan atau sudah selesai'}), 400

            # Add points
            cursor.execute("SELECT points FROM missions WHERE id = %s", (mission_id,))
            mission = cursor.fetchone()
            if mission:
                cursor.execute("UPDATE users SET points = points + %s WHERE id = %s", (mission['points'], user['id']))

        conn.commit()
        return jsonify({'message': 'Check-in berhasil, poin ditambahkan!'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

if __name__ == '__main__':
    # Run the app on all interfaces, port 5000
    app.run(host='0.0.0.0', port=5000, debug=True)
