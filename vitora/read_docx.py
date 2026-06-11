import zipfile
import xml.etree.ElementTree as ET
import sys

def read_docx(file_path):
    try:
        with zipfile.ZipFile(file_path) as z:
            xml_content = z.read('word/document.xml')
            root = ET.fromstring(xml_content)
            ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
            text = '\n'.join([node.text for node in root.iter(f'{{{ns["w"]}}}t') if node.text])
            with open('proposal_extracted.txt', 'w', encoding='utf-8') as f:
                f.write(text)
            print("Extraction successful")
    except Exception as e:
        print("Error:", e)

if __name__ == "__main__":
    read_docx(sys.argv[1])
