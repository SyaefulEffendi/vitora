from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3
import os
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import date, datetime, timedelta

app = Flask(__name__)
CORS(app)  # Allow frontend to communicate with backend

# Database Configuration
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE_DIR, 'vitora.db')

def get_db_connection():
    try:
        conn = sqlite3.connect(DB_PATH)
        conn.row_factory = sqlite3.Row
        return conn
    except sqlite3.Error as e:
        print(f"Database connection error: {e}")
        return None

def init_db():
    """Create the users table if it doesn't exist."""
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor()
            if True:
                # Table users
                create_users_table = """
                CREATE TABLE IF NOT EXISTS users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
                try:
                    cursor.execute("ALTER TABLE users ADD COLUMN inventory TEXT DEFAULT ''")
                except Exception:
                    pass
                try:
                    cursor.execute("ALTER TABLE users ADD COLUMN cheers INT DEFAULT 0")
                except Exception:
                    pass
                try:
                    cursor.execute("ALTER TABLE users ADD COLUMN streak INT DEFAULT 1")
                except Exception:
                    pass
                try:
                    cursor.execute("ALTER TABLE users ADD COLUMN last_login_date DATE")
                except Exception:
                    pass

                # Table missions
                create_missions_table = """
                CREATE TABLE IF NOT EXISTS missions (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
                        # MENTAL HEALTH
                        ('Jurnal Stres', 'Tulis 3 hal yang membuatmu stres hari ini', 'Mental', 'Easy', 5, 5),
                        ('Pernapasan 4-7-8', 'Lakukan teknik pernapasan 4-7-8 sebelum tidur', 'Mental', 'Easy', 5, 5),
                        ('Journaling Bebas', 'Lakukan journaling bebas tentang perasaanmu', 'Mental', 'Medium', 10, 15),
                        ('Grounding Technique', 'Terapkan teknik grounding 5-4-3-2-1', 'Mental', 'Medium', 10, 5),
                        ('No Complain Day', 'Jalani satu hari penuh tanpa mengeluh', 'Mental', 'Hard', 20, 1440),
                        ('Manajemen Stres 14 Hari', 'Konsisten jalani rutinitas manajemen stres', 'Mental', 'Expert', 50, 20160),
                        ('Tidur Tepat Waktu', 'Tidur sebelum jam 23.00 malam ini', 'Mental', 'Easy', 5, 480),
                        ('Gratitude Journal', 'Tulis 3 hal yang disyukuri hari ini', 'Mental', 'Easy', 5, 5),
                        
                        # SOCIAL HEALTH
                        ('Asertif: Berpendapat', 'Ungkapkan satu pendapatmu dengan jelas dan sopan', 'Social', 'Easy', 5, 5),
                        ('Katakan Tidak', 'Katakan tidak untuk permintaan di luar kapasitas', 'Social', 'Easy', 5, 5),
                        ('Minta Bantuan', 'Minta bantuan atau apa yang kamu butuhkan langsung', 'Social', 'Medium', 10, 5),
                        ('Quality Time Keluarga', 'Makan bersama keluarga tanpa pegang HP', 'Social', 'Easy', 5, 30),
                        ('Active Listening', 'Dengarkan orang lain bercerita tanpa menyela', 'Social', 'Medium', 10, 15),
                        ('Sapa Teman Lama', 'Hubungi teman lama hanya untuk say hi', 'Social', 'Easy', 5, 5),
                        ('Volunteer Sehari', 'Ikuti kegiatan sosial/volunteer', 'Social', 'Medium', 10, 180),
                        
                        # PHYSICAL HEALTH
                        ('Jalan Kaki 10 Menit', 'Jalan kaki minimal 10 menit tanpa tujuan', 'Physical', 'Easy', 5, 10),
                        ('Naik Tangga', 'Gunakan tangga sebagai ganti lift/eskalator', 'Physical', 'Easy', 5, 5),
                        ('5000 Langkah', 'Capai 5.000 langkah hari ini', 'Physical', 'Medium', 10, 120),
                        ('Olahraga 30 Menit', 'Jalani olahraga rutin 30 menit hari ini', 'Physical', 'Hard', 20, 30),
                        ('Minum 2 Liter Air', 'Penuhi kebutuhan air putih 2 liter hari ini', 'Physical', 'Medium', 10, 1440),
                        ('Sarapan Sehat', 'Makan sarapan sebelum jam 09.00', 'Physical', 'Easy', 5, 15),
                        ('Aturan 20-20-20', 'Terapkan aturan istirahat mata setiap 20 menit', 'Physical', 'Medium', 10, 20)
                    ]
                    insert_mission = "INSERT INTO missions (title, subtitle, category, difficulty, points, duration_minutes) VALUES (?, ?, ?, ?, ?, ?)"
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
        cursor = conn.cursor()
        if True:
            # Check if user already exists
            cursor.execute("SELECT * FROM users WHERE email = ?", (email,))
            if cursor.fetchone():
                return jsonify({'error': 'Email sudah terdaftar'}), 400

            # Get current date
            current_date = date.today().strftime('%Y-%m-%d')

            # Insert new user
            hashed_password = generate_password_hash(password)
            sql = "INSERT INTO users (nama, nomor_telepon, email, password_hash, avatar, last_login_date) VALUES (?, ?, ?, ?, ?, ?)"
            cursor.execute(sql, (nama, nomor_telepon, email, hashed_password, avatar, current_date))
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
        cursor = conn.cursor()
        if True:
            cursor.execute("SELECT * FROM users WHERE email = ?", (email,))
            user_row = cursor.fetchone()
            user = dict(user_row) if user_row else None

            if user and check_password_hash(user['password_hash'], password):
                # Streak Calculation
                today = date.today()
                
                streak = user.get('streak', 1)
                last_login = user.get('last_login_date')
                
                if last_login:
                    if isinstance(last_login, str):
                        try:
                            last_login = datetime.strptime(last_login, '%Y-%m-%d').date()
                        except:
                            last_login = today
                            
                    delta = today - last_login
                    if delta.days == 1:
                        # Logged in yesterday, increment streak
                        streak += 1
                    elif delta.days > 1:
                        # Missed a day, reset streak
                        streak = 1
                
                # Update last_login_date and streak
                cursor.execute("UPDATE users SET last_login_date = ?, streak = ? WHERE email = ?", (today.strftime('%Y-%m-%d'), streak, email))
                conn.commit()

                # Calculate level
                points = user.get('points', 0)
                level = (points // 250) + 1
                next_level_points = level * 250
                
                user_data = {
                    'id': user['id'],
                    'nama': user['nama'],
                    'email': user['email'],
                    'avatar': user['avatar'],
                    'focus_categories': user['focus_categories'],
                    'points': points,
                    'level': level,
                    'next_level_points': next_level_points
                }
                return jsonify({
                    'message': 'Login berhasil',
                    'user': user_data
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
        cursor = conn.cursor()
        if True:
            cursor.execute("UPDATE users SET focus_categories = ? WHERE email = ?", (categories, email))
            if cursor.rowcount == 0:
                return jsonify({'error': 'User tidak ditemukan'}), 404
        conn.commit()
        return jsonify({'message': 'Kategori berhasil disimpan!'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@app.route('/api/user/profile', methods=['GET'])
def get_user_profile():
    email = request.args.get('email')
    if not email:
        return jsonify({'error': 'Email diperlukan'}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor()
        if True:
            cursor.execute("SELECT id, nama, email, avatar, focus_categories, points, inventory, streak FROM users WHERE email = ?", (email,))
            user_row = cursor.fetchone()
            user = dict(user_row) if user_row else None
            if not user:
                return jsonify({'error': 'User tidak ditemukan'}), 404
            
            # Calculate level: Level 1 starts at 0, Level 2 at 250, Level 3 at 500, etc.
            points = user['points']
            level = (points // 250) + 1
            next_level_points = level * 250
            streak = user.get('streak', 1)

            user_info = {
                'id': user['id'],
                'nama': user['nama'],
                'email': user['email'],
                'avatar': user['avatar'],
                'focus_categories': user['focus_categories'],
                'inventory': user['inventory'] if user['inventory'] else '',
                'points': points,
                'level': level,
                'streak': streak,
                'next_level_points': next_level_points
            }
            return jsonify({'user': user_info}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@app.route('/api/leaderboard', methods=['GET'])
def get_leaderboard():
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor()
        if True:
            # Get top 20 users by points
            cursor.execute("SELECT id, nama, email, avatar, points, cheers, streak FROM users ORDER BY points DESC LIMIT 20")
            users_rows = cursor.fetchall()
            users = [dict(row) for row in users_rows]
            
            # Calculate levels for leaderboard
            leaderboard = []
            for u in users:
                lvl = (u['points'] // 250) + 1
                leaderboard.append({
                    'id': u['id'],
                    'nama': u['nama'],
                    'email': u['email'],
                    'avatar': u['avatar'],
                    'points': u['points'],
                    'cheers': u['cheers'] if 'cheers' in u else 0,
                    'streak': u['streak'] if 'streak' in u else 1,
                    'level': lvl
                })
            
            return jsonify({'leaderboard': leaderboard}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@app.route('/api/shop/redeem', methods=['POST'])
def redeem_points():
    data = request.get_json()
    email = data.get('email')
    cost = data.get('cost')
    reward_name = data.get('reward_name')

    if not email or cost is None:
        return jsonify({'error': 'Email dan cost diperlukan'}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor()
        if True:
            # Get current points
            cursor.execute("SELECT points FROM users WHERE email = ?", (email,))
            user_row = cursor.fetchone()
            user = dict(user_row) if user_row else None
            if not user:
                return jsonify({'error': 'User tidak ditemukan'}), 404
            
            if user['points'] < cost:
                return jsonify({'error': 'Poin tidak cukup'}), 400

            # Deduct points
            new_points = user['points'] - cost
            cursor.execute("UPDATE users SET points = ? WHERE email = ?", (new_points, email))
        
        conn.commit()
        return jsonify({'message': f'Berhasil menukar {cost} poin untuk {reward_name}! Sisa poin: {new_points}'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@app.route('/api/shop/buy_item', methods=['POST'])
def buy_item():
    data = request.get_json()
    email = data.get('email')
    cost = data.get('cost')
    item_id = data.get('item_id')

    if not email or cost is None or not item_id:
        return jsonify({'error': 'Email, cost, dan item_id diperlukan'}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor()
        if True:
            # Get current points and inventory
            cursor.execute("SELECT points, inventory FROM users WHERE email = ?", (email,))
            user_row = cursor.fetchone()
            user = dict(user_row) if user_row else None
            if not user:
                return jsonify({'error': 'User tidak ditemukan'}), 404
            
            if user['points'] < cost:
                return jsonify({'error': 'Poin tidak cukup'}), 400

            inventory = user['inventory'] if user['inventory'] else ''
            
            # Check if already owned
            items = inventory.split(',') if inventory else []
            if item_id in items:
                return jsonify({'error': 'Item sudah dimiliki'}), 400

            # Deduct points and add item
            new_points = user['points'] - cost
            items.append(item_id)
            new_inventory = ','.join(filter(None, items))
            
            cursor.execute("UPDATE users SET points = ?, inventory = ? WHERE email = ?", (new_points, new_inventory, email))
        
        conn.commit()
        return jsonify({'message': f'Berhasil membeli item! Sisa poin: {new_points}', 'inventory': new_inventory}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@app.route('/api/social/cheer', methods=['POST'])
def send_cheer():
    data = request.get_json()
    target_email = data.get('target_email')

    if not target_email:
        return jsonify({'error': 'Target email diperlukan'}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor()
        if True:
            # Increment cheer count
            cursor.execute("UPDATE users SET cheers = cheers + 1 WHERE email = ?", (target_email,))
            if cursor.rowcount == 0:
                return jsonify({'error': 'User tidak ditemukan'}), 404
        
        conn.commit()
        return jsonify({'message': 'Berhasil memberikan cheer!'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@app.route('/api/user/avatar', methods=['POST'])
def update_avatar():
    data = request.get_json()
    email = data.get('email')
    avatar_id = data.get('avatar_id')

    if not email or not avatar_id:
        return jsonify({'error': 'Email dan avatar_id diperlukan'}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor()
        if True:
            # We don't check if they own the avatar right now for simplicity, 
            # but ideally we would check against inventory.
            cursor.execute("UPDATE users SET avatar = ? WHERE email = ?", (avatar_id, email))
            if cursor.rowcount == 0:
                return jsonify({'error': 'User tidak ditemukan'}), 404
        
        conn.commit()
        return jsonify({'message': 'Avatar berhasil diperbarui!'}), 200
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
        cursor = conn.cursor()
        if True:
            # Get user info and focus categories
            if email:
                cursor.execute("SELECT id, focus_categories FROM users WHERE email = ?", (email,))
                user_row = cursor.fetchone()
                user = dict(user_row) if user_row else None
                if user:
                    user_id = user['id']
                    categories = [cat.strip() for cat in user['focus_categories'].split(',') if cat.strip()]
                    categories = ['Physical' if c == 'Fisik' else 'Social' if c == 'Sosial' else c for c in categories]
                    
                    query = """
                        SELECT m.*, um.status as user_status
                        FROM missions m
                        LEFT JOIN user_missions um ON m.id = um.mission_id AND um.user_id = ?
                    """
                    params = [user_id]
                    
                    if categories:
                        format_strings = ','.join(['?'] * len(categories))
                        query += f" WHERE m.category IN ({format_strings})"
                        params.extend(categories)
                        
                    cursor.execute(query, tuple(params))
                else:
                    cursor.execute("SELECT * FROM missions")
            else:
                cursor.execute("SELECT * FROM missions")
            
            missions_rows = cursor.fetchall()
            missions = [dict(row) for row in missions_rows]
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
        cursor = conn.cursor()
        if True:
            cursor.execute("SELECT id FROM users WHERE email = ?", (email,))
            user_row = cursor.fetchone()
            user = dict(user_row) if user_row else None
            if not user:
                return jsonify({'error': 'User tidak ditemukan'}), 404

            # Check if already underway
            cursor.execute("SELECT id FROM user_missions WHERE user_id = ? AND mission_id = ? AND status = 'underway'", (user['id'], mission_id))
            if cursor.fetchone():
                return jsonify({'error': 'Misi sudah berjalan'}), 400

            cursor.execute("INSERT INTO user_missions (user_id, mission_id, status) VALUES (?, ?, 'underway')", (user['id'], mission_id))
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

        cursor = conn.cursor()
        if True:
            cursor.execute("SELECT id FROM users WHERE email = ?", (email,))
            user_row = cursor.fetchone()
            user = dict(user_row) if user_row else None
            if not user:
                return jsonify({'error': 'User tidak ditemukan'}), 404

            # Mark mission as completed
            cursor.execute("""
                UPDATE user_missions 
                SET status = 'completed', proof_image_path = ?, completed_at = CURRENT_TIMESTAMP
                WHERE user_id = ? AND mission_id = ? AND status = 'underway'
            """, (file_path, user['id'], mission_id))
            
            if cursor.rowcount == 0:
                return jsonify({'error': 'Misi tidak ditemukan atau sudah selesai'}), 400

            # Add points
            cursor.execute("SELECT points FROM missions WHERE id = ?", (mission_id,))
            mission_row = cursor.fetchone()
            mission = dict(mission_row) if mission_row else None
            if mission:
                cursor.execute("UPDATE users SET points = points + ? WHERE id = ?", (mission['points'], user['id']))

        conn.commit()
        return jsonify({'message': 'Check-in berhasil, poin ditambahkan!'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

@app.route('/api/missions/fail', methods=['POST'])
def fail_mission():
    data = request.get_json()
    email = data.get('email')
    mission_id = data.get('mission_id')

    if not email or not mission_id:
        return jsonify({'error': 'Email dan mission_id diperlukan'}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor()
        if True:
            cursor.execute("SELECT id, points FROM users WHERE email = ?", (email,))
            user_row = cursor.fetchone()
            user = dict(user_row) if user_row else None
            if not user:
                return jsonify({'error': 'User tidak ditemukan'}), 404

            # Mark mission as failed
            cursor.execute("""
                UPDATE user_missions 
                SET status = 'failed'
                WHERE user_id = ? AND mission_id = ? AND status = 'underway'
            """, (user['id'], mission_id))
            
            if cursor.rowcount == 0:
                return jsonify({'error': 'Misi tidak ditemukan atau sudah selesai/gagal'}), 400

            # Calculate new points with Checkpoint logic
            current_points = user['points']
            # Checkpoint is every 250 points
            new_points = (current_points // 250) * 250
            
            cursor.execute("UPDATE users SET points = ? WHERE id = ?", (new_points, user['id']))

        conn.commit()
        return jsonify({'message': f'Misi gagal. Poin Anda diturunkan ke checkpoint terdekat ({new_points} PTS).', 'new_points': new_points}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        conn.close()

if __name__ == '__main__':
    # Run the app on all interfaces, port 5000
    app.run(host='0.0.0.0', port=5000, debug=True)
