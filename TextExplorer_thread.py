import os
import threading
import time

folder_path = r"C:\..."
search_term = "Text"

total_files = 0
files_found = 0
found_files = []
lock = threading.Lock()

def search_file(file_path):
    global total_files, files_found, found_files
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            if search_term in file.read():
                with lock:
                    files_found += 1
                    found_files.append(file_path)
    except UnicodeDecodeError:
        pass
    with lock:
        total_files += 1

def main():
    start_time = time.time()
    threads = []
    for root, dirs, files in os.walk(folder_path):
        for filename in files:
            file_path = os.path.join(root, filename)
            thread = threading.Thread(target=search_file, args=(file_path,))
            thread.start()
            threads.append(thread)

    for thread in threads:
        thread.join()

    end_time = time.time()
    total_time = end_time - start_time

    print(f"Total de arquivos lidos: {total_files}")
    print(f"Arquivos encontrados com a palavra '{search_term}': {files_found}")

    if found_files:
        print("\nCaminhos dos arquivos encontrados:")
        for file_path in found_files:
            print(file_path)
    else:
        print("\nNenhum arquivo encontrado com a palavra 'Powered'.")

    print(f"\nTempo total de execução: {total_time:.2f} segundos")

if __name__ == "__main__":
    main()
