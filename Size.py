import os

def calcular_tamanho_pasta(caminho):
    total_tamanho = 0
    for raiz, dirs, arquivos in os.walk(caminho):
        for nome in arquivos:
            caminho_completo = os.path.join(raiz, nome)
            total_tamanho += os.path.getsize(caminho_completo)
    return total_tamanho

def listar_arquivos_e_diretorios():
    lista = []

    # Caminha pelo diretório atual
    for item in os.listdir('.'):
        if os.path.isdir(item):
            tamanho = calcular_tamanho_pasta(item)
            lista.append((item, tamanho / 1024))  # Converte para KB
        elif os.path.isfile(item):
            tamanho = os.path.getsize(item)
            lista.append((item, tamanho / 1024))  # Converte para KB

    # Ordena a lista por tamanho em ordem decrescente
    lista.sort(key=lambda x: x[1], reverse=True)

    # Exibe os resultados em formato de tabela
    print(f"{'Diretório/Arquivo':<50} | {'Tamanho (KB)':>15}")
    print('-' * 70)
    for caminho, tamanho in lista:
        print(f"{caminho:<50} | {tamanho:>15.2f}")

# Executa a função
listar_arquivos_e_diretorios()
