import os

folder_path = r"C:\..."
search_term = "Text"

total_files = 0
files_found = 0
found_files = []

for root, dirs, files in os.walk(folder_path):
    for filename in files:
        file_path = os.path.join(root, filename)
        total_files += 1
        #print(f"Lendo arquivo: {file_path}")
        try:
            with open(file_path, 'r', encoding='utf-8') as file:
                if search_term in file.read():
                    files_found += 1
                    found_files.append(file_path)
                    #print(f"Arquivo encontrado: {file_path}")
        except UnicodeDecodeError:
            #print(f"Não foi possível ler o arquivo: {file_path}")
            pass
            

print(f"Total de arquivos lidos: {total_files}")
print(f"Arquivos encontrados com a palavra '{search_term}': {files_found}")

if found_files:
    print("\nCaminhos dos arquivos encontrados:")
    for file_path in found_files:
        print(file_path)
else:
    print("\nNenhum arquivo encontrado com a palavra 'Powered'.")

print("\nPesquisa concluída.")
