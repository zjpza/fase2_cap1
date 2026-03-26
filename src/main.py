import math
import sys

# ── Vetores (listas paralelas que armazenam os dados dos talhoes) ──
nomes = []       # nome de cada talhao
culturas = []    # tipo de cultura (Cana-de-acucar ou Laranja)
areas = []       # area calculada em m2
insumos = []     # nome do insumo utilizado
qtds = []        # quantidade de insumo em litros
ruas = []        # numero de ruas da lavoura


# ── Helpers (funcoes auxiliares de validacao de entrada) ──
def ler_float(mensagem):
    """Le um numero decimal do usuario, repetindo ate receber um valor valido."""
    while True:
        try:
            return float(input(mensagem))
        except ValueError:
            print("  Valor invalido. Digite um numero.")


def ler_int(mensagem):
    """Le um numero inteiro do usuario, repetindo ate receber um valor valido."""
    while True:
        try:
            return int(input(mensagem))
        except ValueError:
            print("  Valor invalido. Digite um numero inteiro.")


def ler_indice(tamanho):
    """Le um indice valido entre 0 e tamanho-1, repetindo ate receber um valor valido."""
    while True:
        i = ler_int("\n  Indice: ")
        if 0 <= i < tamanho:
            return i
        print(f"  Indice invalido. Digite entre 0 e {tamanho - 1}.")


# ── Calculo de area ──────────────────────────────────────
def calc_area(cultura):
    """Calcula a area do talhao conforme a cultura escolhida.
    Cana: area do retangulo (comprimento x largura).
    Laranja: area da elipse (pi x semi-eixo a x semi-eixo b).
    Retorna a area em m2 e o comprimento/semi-eixo maior (usado no calculo de insumo).
    """
    if cultura == "1":  # Cana -> Retangulo
        c = ler_float("  Comprimento (m): ")
        l = ler_float("  Largura (m): ")
        return round(c * l, 2), c
    else:               # Laranja -> Elipse
        a = ler_float("  Semi-eixo maior (m): ")
        b = ler_float("  Semi-eixo menor (m): ")
        return round(math.pi * a * b, 2), a


# ── Calculo de insumo ────────────────────────────────────
def calc_insumo(comp_rua):
    """Calcula a quantidade total de insumo em litros.
    Formula: (dose_mL_por_metro * comprimento_rua * num_ruas) / 1000
    Retorna o nome do insumo, a quantidade em litros e o numero de ruas.
    """
    nome = input("  Nome do insumo (ex: herbicida): ")
    dose = ler_float("  Dose (mL por metro): ")
    n_ruas = ler_int("  Numero de ruas: ")
    total = (dose * comp_rua * n_ruas) / 1000  # converte para litros
    return nome, round(total, 2), n_ruas


# ── CRUD (Criar, Ler, Atualizar, Deletar) ───────────────
def cadastrar():
    """Cadastra um novo talhao com cultura, area e insumo nos vetores."""
    print("\n── Cadastro ──")

    nome = input("  Nome do talhao: ")
    if nomes.count(nome) > 0:
        print("  Ja existe um talhao com este nome")
        return

    print("  Cultura: 1-Cana  2-Laranja")
    c = input("  Escolha: ")
    if c not in ("1", "2"):
        print("  Opcao invalida. Cadastro cancelado.")
        return

    cultura = "Cana-de-acucar" if c == "1" else "Laranja"
    area, comp = calc_area(c)
    ins, qtd, n = calc_insumo(comp)

    nomes.append(nome)
    culturas.append(cultura)
    areas.append(area)
    insumos.append(ins)
    qtds.append(qtd)
    ruas.append(n)
    print(f"\n  Area: {area} m2  |  Insumo: {qtd} L de {ins}")


def exibir():
    """Exibe todos os registros em formato de tabela no terminal."""
    if not nomes:
        print("\n  Nenhum registro.")
        return
    print(f"\n{'#':<4}{'Talhao':<15}{'Cultura':<18}{'Area(m2)':<12}"
          f"{'Insumo':<15}{'Qtd(L)':<10}{'Ruas'}")
    print("-" * 74)
    for i in range(len(nomes)):
        print(f"{i:<4}{nomes[i]:<15}{culturas[i]:<18}{areas[i]:<12}"
              f"{insumos[i]:<15}{qtds[i]:<10}{ruas[i]}")


def atualizar():
    """Atualiza um registro existente pelo indice, recadastrando todos os campos."""
    exibir()
    if not nomes:
        return
    i = ler_indice(len(nomes))
    print("  Recadastrando posicao", i)
    nomes[i] = input("  Novo nome: ")
    print("  1-Cana  2-Laranja")
    c = input("  Cultura: ")
    if c not in ("1", "2"):
        print("  Opcao invalida. Atualizacao cancelada.")
        return
    culturas[i] = "Cana-de-acucar" if c == "1" else "Laranja"
    areas[i], comp = calc_area(c)
    insumos[i], qtds[i], ruas[i] = calc_insumo(comp)
    print("  Registro atualizado.")


def deletar():
    """Remove um registro pelo indice de todos os vetores."""
    exibir()
    if not nomes:
        return
    i = ler_indice(len(nomes))
    for v in [nomes, culturas, areas, insumos, qtds, ruas]:
        v.pop(i)
    print("  Registro removido.")


# ── Menu principal ───────────────────────────────────────
def menu():
    """Loop principal do programa. Exibe o menu e direciona para a funcao escolhida."""
    opcoes = {
        "1": cadastrar,
        "2": exibir,
        "3": atualizar,
        "4": deletar,
    }
    while True:
        print("""
==============================
     FarmTech Solutions
==============================
  1. Cadastrar nova area
  2. Exibir registros
  3. Atualizar registro
  4. Deletar registro
  5. Sair
==============================""")
        op = input("  Opcao: ").strip()
        if op == "5":
            print("  Encerrando... Ate logo!")
            sys.exit()
        elif op in opcoes:
            opcoes[op]()
        else:
            print("  Opcao invalida.")


if __name__ == "__main__":
    menu()
