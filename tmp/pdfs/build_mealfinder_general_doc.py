from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import (
    BaseDocTemplate,
    Frame,
    KeepTogether,
    PageBreak,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "output" / "pdf" / "MealFinder_Documentacao_Geral.pdf"
API_BASE = "https://www.themealdb.com/api/json/v1/1/"

ORANGE = colors.HexColor("#FF6B35")
INK = colors.HexColor("#1A1A1A")
MUTED = colors.HexColor("#6B7280")
BACKGROUND = colors.HexColor("#F8F9FA")
SOFT_ORANGE = colors.HexColor("#FFF0EA")
LINE = colors.HexColor("#E7E9EC")


def paragraph(text, style):
    return Paragraph(text.replace("\n", "<br/>"), style)


def endpoint_link(label, path):
    return (
        f'<a href="{API_BASE}{path}" color="#B74925"><u>{label}</u></a>'
    )


def section_title(text, styles):
    return [
        Spacer(1, 0.22 * cm),
        Paragraph(text, styles["section"]),
        Spacer(1, 0.18 * cm),
    ]


def info_card(title, body, styles, width):
    table = Table(
        [[Paragraph(title, styles["card_title"])], [Paragraph(body, styles["card_body"])]] ,
        colWidths=[width],
    )
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), colors.white),
                ("BOX", (0, 0), (-1, -1), 0.7, LINE),
                ("LINEBEFORE", (0, 0), (0, -1), 3, ORANGE),
                ("LEFTPADDING", (0, 0), (-1, -1), 13),
                ("RIGHTPADDING", (0, 0), (-1, -1), 13),
                ("TOPPADDING", (0, 0), (-1, 0), 12),
                ("BOTTOMPADDING", (0, -1), (-1, -1), 12),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ]
        )
    )
    return table


def page_background(canvas, doc):
    canvas.saveState()
    canvas.setFillColor(BACKGROUND)
    canvas.rect(0, 0, A4[0], A4[1], fill=1, stroke=0)
    canvas.setFillColor(ORANGE)
    canvas.rect(0, A4[1] - 0.22 * cm, A4[0], 0.22 * cm, fill=1, stroke=0)
    canvas.restoreState()


def build_pdf():
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    document = BaseDocTemplate(
        str(OUTPUT),
        pagesize=A4,
        leftMargin=1.7 * cm,
        rightMargin=1.7 * cm,
        topMargin=1.55 * cm,
        bottomMargin=1.65 * cm,
        title="MealFinder - Documentacao Geral",
        author="MealFinder",
    )
    frame = Frame(
        document.leftMargin,
        document.bottomMargin,
        document.width,
        document.height,
        id="content",
    )
    from reportlab.platypus import PageTemplate

    document.addPageTemplates([PageTemplate(id="meal", frames=[frame], onPage=page_background)])

    base = getSampleStyleSheet()
    styles = {
        "eyebrow": ParagraphStyle(
            "eyebrow",
            parent=base["Normal"],
            fontName="Helvetica-Bold",
            fontSize=10,
            leading=13,
            textColor=ORANGE,
            spaceAfter=9,
        ),
        "hero": ParagraphStyle(
            "hero",
            parent=base["Normal"],
            fontName="Helvetica-Bold",
            fontSize=31,
            leading=35,
            textColor=INK,
            spaceAfter=9,
        ),
        "subtitle": ParagraphStyle(
            "subtitle",
            parent=base["Normal"],
            fontName="Helvetica",
            fontSize=13,
            leading=19,
            textColor=MUTED,
            spaceAfter=15,
        ),
        "section": ParagraphStyle(
            "section",
            parent=base["Normal"],
            fontName="Helvetica-Bold",
            fontSize=18,
            leading=22,
            textColor=INK,
            spaceAfter=4,
        ),
        "body": ParagraphStyle(
            "body",
            parent=base["Normal"],
            fontName="Helvetica",
            fontSize=10.3,
            leading=15,
            textColor=INK,
        ),
        "small": ParagraphStyle(
            "small",
            parent=base["Normal"],
            fontName="Helvetica",
            fontSize=8.8,
            leading=12.5,
            textColor=MUTED,
        ),
        "card_title": ParagraphStyle(
            "card_title",
            parent=base["Normal"],
            fontName="Helvetica-Bold",
            fontSize=11,
            leading=14,
            textColor=INK,
            spaceAfter=5,
        ),
        "card_body": ParagraphStyle(
            "card_body",
            parent=base["Normal"],
            fontName="Helvetica",
            fontSize=9.2,
            leading=13.5,
            textColor=MUTED,
        ),
        "table_head": ParagraphStyle(
            "table_head",
            parent=base["Normal"],
            fontName="Helvetica-Bold",
            fontSize=8.8,
            leading=11,
            textColor=colors.white,
        ),
        "table_body": ParagraphStyle(
            "table_body",
            parent=base["Normal"],
            fontName="Helvetica",
            fontSize=8.5,
            leading=11.5,
            textColor=INK,
        ),
    }

    story = []

    # Page 1 - overview
    story.extend(
        [
            Spacer(1, 1.2 * cm),
            Paragraph("PROJETO FLUTTER", styles["eyebrow"]),
            Paragraph("MealFinder", styles["hero"]),
            Paragraph(
                "Aplicativo de receitas internacionais que ajuda a descobrir, buscar, filtrar, salvar e preparar pratos usando dados da TheMealDB.",
                styles["subtitle"],
            ),
        ]
    )
    summary = Table(
        [
            [
                Paragraph("<b>Objetivo</b><br/>Projeto academico com uma experiencia simples de descoberta de receitas.", styles["card_body"]),
                Paragraph("<b>Plataforma</b><br/>Flutter para Android, desktop e navegador.", styles["card_body"]),
                Paragraph("<b>Fonte de dados</b><br/>API publica TheMealDB, somente com requisicoes GET.", styles["card_body"]),
            ]
        ],
        colWidths=[document.width / 3] * 3,
    )
    summary.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), SOFT_ORANGE),
                ("BOX", (0, 0), (-1, -1), 0.5, colors.HexColor("#FFD2C3")),
                ("INNERGRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#FFD2C3")),
                ("LEFTPADDING", (0, 0), (-1, -1), 13),
                ("RIGHTPADDING", (0, 0), (-1, -1), 13),
                ("TOPPADDING", (0, 0), (-1, -1), 16),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 16),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ]
        )
    )
    story.extend([summary])
    story.extend(section_title("O que o app entrega", styles))
    cards = [
        info_card("Descoberta", "Home com categorias, destaques e uma receita aleatoria para sair da rotina.", styles, document.width / 2 - 0.18 * cm),
        info_card("Busca e filtros", "Busca por nome e filtros reais por categoria, regiao ou ingrediente.", styles, document.width / 2 - 0.18 * cm),
        info_card("Detalhes", "Imagem, ingredientes, medidas, modo de preparo, video e compartilhamento.", styles, document.width / 2 - 0.18 * cm),
        info_card("Favoritos", "IDs salvos no dispositivo e receitas carregadas novamente pela API quando necessario.", styles, document.width / 2 - 0.18 * cm),
    ]
    cards_table = Table([[cards[0], cards[1]], [cards[2], cards[3]]], colWidths=[document.width / 2, document.width / 2], hAlign="LEFT")
    cards_table.setStyle(TableStyle([("VALIGN", (0, 0), (-1, -1), "TOP"), ("LEFTPADDING", (0, 0), (-1, -1), 0), ("RIGHTPADDING", (0, 0), (-1, -1), 7), ("BOTTOMPADDING", (0, 0), (-1, -1), 9)]))
    story.extend([cards_table, Spacer(1, 0.2 * cm)])
    story.append(Paragraph('Navegacao: Inicio, Buscar, Favoritos e Perfil.', styles["small"]))
    story.append(PageBreak())

    # Page 2 - architecture and API
    story.extend(section_title("Arquitetura e integracao", styles))
    story.append(Paragraph("A aplicacao usa uma estrutura direta, com responsabilidades separadas para facilitar manutencao e evolucao.", styles["body"]))
    story.append(Spacer(1, 0.25 * cm))
    flow = Table(
        [[
            Paragraph("<b>Telas e widgets</b><br/>Interface, navegacao e estados visuais.", styles["card_body"]),
            Paragraph("<b>Provider</b><br/>Estado de navegacao, busca e favoritos.", styles["card_body"]),
            Paragraph("<b>Services</b><br/>TheMealDB e armazenamento local.", styles["card_body"]),
            Paragraph("<b>Modelos</b><br/>Resumo, detalhe, categoria e ingredientes.", styles["card_body"]),
        ]],
        colWidths=[document.width / 4] * 4,
    )
    flow.setStyle(TableStyle([("BACKGROUND", (0, 0), (-1, -1), colors.white), ("BOX", (0, 0), (-1, -1), 0.7, LINE), ("INNERGRID", (0, 0), (-1, -1), 0.5, LINE), ("LEFTPADDING", (0, 0), (-1, -1), 10), ("RIGHTPADDING", (0, 0), (-1, -1), 10), ("TOPPADDING", (0, 0), (-1, -1), 14), ("BOTTOMPADDING", (0, 0), (-1, -1), 14), ("VALIGN", (0, 0), (-1, -1), "TOP")]))
    story.extend([flow])
    story.extend(section_title("API utilizada", styles))
    api_rows = [
        ["Tela ou acao", "Endpoint", "Uso"],
        [
            "Inicio",
            f"{endpoint_link('search.php?s=chicken', 'search.php?s=chicken')}<br/>{endpoint_link('categories.php', 'categories.php')}",
            "Destaques e categorias",
        ],
        [
            "Buscar",
            endpoint_link('search.php?s={nome}', 'search.php?s=Arrabiata') +
                '<br/>' +
                endpoint_link('filter.php?c/a/i={valor}', 'filter.php?c=Seafood'),
            "Nome, categoria, regiao e ingrediente",
        ],
        [
            "Detalhes",
            endpoint_link('lookup.php?i={idMeal}', 'lookup.php?i=52772'),
            "Receita completa, ingredientes e instrucoes",
        ],
        [
            "Descobrir",
            endpoint_link('random.php', 'random.php'),
            "Sugestao aleatoria",
        ],
        [
            "Favoritos",
            endpoint_link('lookup.php?i={idMeal}', 'lookup.php?i=52772'),
            "Hidratacao dos IDs locais",
        ],
    ]
    api_table = Table(
        [[paragraph(str(cell), styles["table_body"] if row_index else styles["table_head"]) for cell in row] for row_index, row in enumerate(api_rows)],
        colWidths=[3.1 * cm, 6.3 * cm, document.width - 9.4 * cm],
        repeatRows=1,
    )
    api_table.setStyle(TableStyle([("BACKGROUND", (0, 0), (-1, 0), ORANGE), ("BACKGROUND", (0, 1), (-1, -1), colors.white), ("GRID", (0, 0), (-1, -1), 0.5, LINE), ("VALIGN", (0, 0), (-1, -1), "TOP"), ("LEFTPADDING", (0, 0), (-1, -1), 9), ("RIGHTPADDING", (0, 0), (-1, -1), 9), ("TOPPADDING", (0, 0), (-1, -1), 8), ("BOTTOMPADDING", (0, 0), (-1, -1), 8)]))
    story.append(api_table)
    story.extend(section_title("Dados editoriais", styles))
    story.append(Paragraph("A API nao fornece nota, tempo, dificuldade, porcoes ou descricao curta. Esses dados sao gerados localmente a partir do id da receita, de forma deterministica. Assim, uma receita mantem os mesmos valores em todas as aberturas.", styles["body"]))
    story.append(Spacer(1, 0.12 * cm))
    story.append(Paragraph('Os atalhos "Refeicoes rapidas" e "Jantar" tambem sao editoriais: eles enviam, respectivamente, as categorias Chicken e Beef para a API.', styles["small"]))
    story.append(PageBreak())

    # Page 3 - local data, run, quality
    story.extend(section_title("Experiencia e qualidade", styles))
    story.append(Paragraph("A interface foi desenhada para ser leve e objetiva: fundo claro, cartoes brancos, destaque em laranja (#FF6B35) e navegacao inferior flutuante.", styles["body"]))
    story.append(Spacer(1, 0.22 * cm))
    experience = Table(
        [
            [Paragraph("<b>Estados tratados</b><br/>Carregamento, sucesso, vazio, erro e nova tentativa em todas as telas com dados remotos.", styles["card_body"]), Paragraph("<b>Resiliencia</b><br/>Tratamento de timeout, erro HTTP, falha de rede, JSON invalido, meals nulo e imagens indisponiveis.", styles["card_body"])],
            [Paragraph("<b>Favoritos locais</b><br/>Somente IDs sao persistidos com SharedPreferences. Nenhum favorito depende de endpoint proprio.", styles["card_body"]), Paragraph("<b>Video opcional</b><br/>O botao de tutorial aparece apenas quando a receita possui uma URL valida de video.", styles["card_body"])],
        ],
        colWidths=[document.width / 2, document.width / 2],
    )
    experience.setStyle(TableStyle([("BACKGROUND", (0, 0), (-1, -1), colors.white), ("GRID", (0, 0), (-1, -1), 0.5, LINE), ("LEFTPADDING", (0, 0), (-1, -1), 13), ("RIGHTPADDING", (0, 0), (-1, -1), 13), ("TOPPADDING", (0, 0), (-1, -1), 13), ("BOTTOMPADDING", (0, 0), (-1, -1), 13), ("VALIGN", (0, 0), (-1, -1), "TOP")]))
    story.append(experience)
    story.extend(section_title("Como executar", styles))
    run_table = Table(
        [
            [Paragraph("1", styles["card_title"]), Paragraph("Na pasta do projeto, execute <b>flutter pub get</b>.", styles["body"])],
            [Paragraph("2", styles["card_title"]), Paragraph("Execute <b>flutter run</b> e escolha um dispositivo, emulador ou Chrome.", styles["body"])],
            [Paragraph("3", styles["card_title"]), Paragraph("Para verificacao, execute <b>flutter analyze</b> e <b>flutter test</b>.", styles["body"])],
        ],
        colWidths=[1.1 * cm, document.width - 1.1 * cm],
    )
    run_table.setStyle(TableStyle([("BACKGROUND", (0, 0), (0, -1), SOFT_ORANGE), ("BACKGROUND", (1, 0), (-1, -1), colors.white), ("GRID", (0, 0), (-1, -1), 0.5, LINE), ("ALIGN", (0, 0), (0, -1), "CENTER"), ("VALIGN", (0, 0), (-1, -1), "MIDDLE"), ("LEFTPADDING", (0, 0), (-1, -1), 11), ("RIGHTPADDING", (0, 0), (-1, -1), 11), ("TOPPADDING", (0, 0), (-1, -1), 10), ("BOTTOMPADDING", (0, 0), (-1, -1), 10)]))
    story.append(run_table)
    story.extend(section_title("Validacoes realizadas", styles))
    checklist = [
        "- 10 endpoints planejados responderam HTTP 200 durante a integracao.",
        "- flutter analyze foi executado sem problemas encontrados.",
        "- flutter test foi executado com teste de parsing do MealDetail aprovado.",
        "- flutter build web foi concluido com sucesso.",
    ]
    story.append(KeepTogether([Paragraph(item, styles["body"]) for item in checklist]))

    document.build(story)


if __name__ == "__main__":
    build_pdf()
    print(OUTPUT)
