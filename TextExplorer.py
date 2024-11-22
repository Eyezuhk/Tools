import os
import time
import zipfile
import xml.etree.ElementTree as ET

def read_docx(file_path):
    try:
        with zipfile.ZipFile(file_path) as zip_file:
            xml_content = zip_file.read('word/document.xml')
            root = ET.fromstring(xml_content)
            namespace = '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}'
            text_elements = root.findall('.//' + namespace + 't')
            text = ''
            for element in text_elements:
                text += element.text
            return text
    except Exception as e:
        #print(f"Erro ao ler o arquivo {file_path}: {str(e)}")
        return ''

def read_pdf(file_path):
    try:
        with open(file_path, 'rb') as file:
            pdf_content = file.read()
            # O formato PDF é binário, então precisamos decodificar o conteúdo
            text = ''
            for byte in pdf_content:
                if 32 <= byte <= 126:  # Caracteres ASCII
                    text += chr(byte)
            return text
    except Exception as e:
        #print(f"Erro ao ler o arquivo {file_path}: {str(e)}")
        return ''

def read_pptx(file_path):
    try:
        with zipfile.ZipFile(file_path) as zip_file:
            xml_content = zip_file.read('ppt/slides/slide1.xml')
            root = ET.fromstring(xml_content)
            namespace = '{http://schemas.openxmlformats.org/drawingml/2006/main}'
            text_elements = root.findall('.//' + namespace + 't')
            text = ''
            for element in text_elements:
                text += element.text
            return text
    except Exception as e:
        #print(f"Erro ao ler o arquivo {file_path}: {str(e)}")
        return ''

def read_xlsx(file_path):
    try:
        with zipfile.ZipFile(file_path) as zip_file:
            xml_content = zip_file.read('xl/worksheets/sheet1.xml')
            root = ET.fromstring(xml_content)
            namespace = '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}'
            text_elements = root.findall('.//' + namespace + 'v')
            text = ''
            for element in text_elements:
                text += element.text
            return text
    except Exception as e:
        #print(f"Erro ao ler o arquivo {file_path}: {str(e)}")
        return ''

def read_csv(file_path):
    try:
        with open(file_path, 'r') as file:
            text = file.read()
            return text
    except Exception as e:
        #print(f"Erro ao ler o arquivo {file_path}: {str(e)}")
        return ''

def read_file(file_path):
    try:
        with open(file_path, 'r') as file:
            return file.read()
    except Exception as e:
        #print(f"Erro ao ler o arquivo {file_path}: {str(e)}")
        return ''

def main():
    while True:
        # Solicita ao usuário o diretório e o termo de busca
        folder_path = input("Digite o caminho do diretório onde deseja procurar: ")
        search_term = input("Digite o termo que deseja procurar: ")
        
        # Verifica se o diretório existe
        if not os.path.isdir(folder_path):
            print("O diretório fornecido não é válido. Verifique o caminho e tente novamente.")
            continue  # Retorna ao início do loop para nova entrada

        start_time = time.time()
        total_files = 0
        files_found = 0
        found_files = []

        for root, dirs, files in os.walk(folder_path):
            for filename in files:
                file_path = os.path.join(root, filename)
                total_files += 1
                
                if filename.endswith('.docx'):
                    text = read_docx(file_path)
                elif filename.endswith('.pdf'):
                    text = read_pdf(file_path)
                elif filename.endswith('.pptx'):
                    text = read_pptx(file_path)
                elif filename.endswith('.xlsx'):
                    text = read_xlsx(file_path)
                elif filename.endswith('.csv'):
                    text = read_csv(file_path)
                else:
                    text = read_file(file_path)
                
                if search_term in text:
                    files_found += 1
                    found_files.append(file_path)

        end_time = time.time()
        total_time = end_time - start_time

        if found_files:
            print("\nCaminhos dos arquivos encontrados:")
            for file_path in found_files:
                print(file_path)
        else:
            print("\nNenhum arquivo encontrado com o termo fornecido.")
        
        print(f"\nTempo de execução da pesquisa: {total_time:.2f} segundos")       
        print(f"Total de arquivos lidos: {total_files}")
        print(f"Arquivos encontrados com a palavra '{search_term}': {files_found}")

        print("\nPesquisa concluída.")

        # Pergunta ao usuário se deseja realizar outra busca
        another_search = input("Deseja procurar outra coisa? (s/n): ").strip().lower()
        if another_search != 's':
            print("Encerrando o programa.")
            break  # Encerra o loop e o programa

if __name__ == "__main__":
    main()
