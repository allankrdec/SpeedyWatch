import Toybox.Graphics;
import Toybox.Lang;

// Desenha a hora em digitos "matriz de pontos" (5x7), como um display de
// LED classico, maiores do que qualquer Graphics.FONT_NUMBER_* disponivel
// nesse dispositivo.

const GLYPH_S = 5;              // tamanho de cada "pixel" do glifo
const GLYPH_COLS = 5;
const GLYPH_ROWS = 7;
const DIGIT_W = GLYPH_S * GLYPH_COLS;  // 25
const DIGIT_H = GLYPH_S * GLYPH_ROWS;  // 35
const COLON_W = GLYPH_S * 3;    // 15
const DIGIT_GAP = 5;

// Matriz 5x7 de cada digito (1 = pixel aceso)
const DIGIT_GLYPH as Array<Array<Array<Number> > > = [
    [ // 0
        [0,1,1,1,0],
        [1,0,0,0,1],
        [1,0,0,1,1],
        [1,0,1,0,1],
        [1,1,0,0,1],
        [1,0,0,0,1],
        [0,1,1,1,0]
    ],
    [ // 1
        [0,0,1,0,0],
        [0,1,1,0,0],
        [0,0,1,0,0],
        [0,0,1,0,0],
        [0,0,1,0,0],
        [0,0,1,0,0],
        [0,1,1,1,0]
    ],
    [ // 2
        [0,1,1,1,0],
        [1,0,0,0,1],
        [0,0,0,0,1],
        [0,0,0,1,0],
        [0,0,1,0,0],
        [0,1,0,0,0],
        [1,1,1,1,1]
    ],
    [ // 3
        [0,1,1,1,0],
        [1,0,0,0,1],
        [0,0,0,0,1],
        [0,0,1,1,0],
        [0,0,0,0,1],
        [1,0,0,0,1],
        [0,1,1,1,0]
    ],
    [ // 4
        [0,0,0,1,0],
        [0,0,1,1,0],
        [0,1,0,1,0],
        [1,0,0,1,0],
        [1,1,1,1,1],
        [0,0,0,1,0],
        [0,0,0,1,0]
    ],
    [ // 5
        [1,1,1,1,1],
        [1,0,0,0,0],
        [1,1,1,1,0],
        [0,0,0,0,1],
        [0,0,0,0,1],
        [1,0,0,0,1],
        [0,1,1,1,0]
    ],
    [ // 6
        [0,0,1,1,0],
        [0,1,0,0,0],
        [1,0,0,0,0],
        [1,1,1,1,0],
        [1,0,0,0,1],
        [1,0,0,0,1],
        [0,1,1,1,0]
    ],
    [ // 7
        [1,1,1,1,1],
        [0,0,0,0,1],
        [0,0,0,1,0],
        [0,0,1,0,0],
        [0,1,0,0,0],
        [0,1,0,0,0],
        [0,1,0,0,0]
    ],
    [ // 8
        [0,1,1,1,0],
        [1,0,0,0,1],
        [1,0,0,0,1],
        [0,1,1,1,0],
        [1,0,0,0,1],
        [1,0,0,0,1],
        [0,1,1,1,0]
    ],
    [ // 9
        [0,1,1,1,0],
        [1,0,0,0,1],
        [1,0,0,0,1],
        [0,1,1,1,1],
        [0,0,0,0,1],
        [0,0,0,1,0],
        [0,1,1,0,0]
    ]
];

function drawBigDigit(dc as Dc, x as Number, y as Number, digit as Number, color as ColorType) as Void {
    var glyph = DIGIT_GLYPH[digit];

    dc.setColor(color, Graphics.COLOR_TRANSPARENT);

    for (var row = 0; row < GLYPH_ROWS; row++) {
        var rowData = glyph[row];
        var col = 0;
        while (col < GLYPH_COLS) {
            if (rowData[col] == 1) {
                var runStart = col;
                while (col < GLYPH_COLS && rowData[col] == 1) {
                    col++;
                }
                dc.fillRectangle(
                    x + runStart * GLYPH_S,
                    y + row * GLYPH_S,
                    (col - runStart) * GLYPH_S,
                    GLYPH_S
                );
            } else {
                col++;
            }
        }
    }
}

function drawBigColon(dc as Dc, x as Number, y as Number, color as ColorType) as Void {
    var dotX = x + (COLON_W - GLYPH_S) / 2;

    dc.setColor(color, Graphics.COLOR_TRANSPARENT);
    dc.fillRectangle(dotX, y + 2 * GLYPH_S, GLYPH_S, GLYPH_S);
    dc.fillRectangle(dotX, y + 4 * GLYPH_S, GLYPH_S, GLYPH_S);
}

function bigTimeTokens(hour as Number, minute as Number) as Array<Number> {
    var tokens = [] as Array<Number>;

    if (hour >= 10) {
        tokens.add(hour / 10);
        tokens.add(hour % 10);
    } else {
        tokens.add(hour);
    }
    tokens.add(-1); // ":"
    tokens.add(minute / 10);
    tokens.add(minute % 10);

    return tokens;
}

function bigTimeWidth(tokens as Array<Number>) as Number {
    var totalWidth = 0;
    for (var i = 0; i < tokens.size(); i++) {
        totalWidth += (tokens[i] == -1) ? COLON_W : DIGIT_W;
    }
    totalWidth += DIGIT_GAP * (tokens.size() - 1);
    return totalWidth;
}

// Desenha "HH:MM" centralizado horizontalmente em screenWidth, com o topo
// dos digitos em y. Retorna o X logo apos o ultimo digito (pra encostar
// o indicador AM/PM, por exemplo).
function drawBigTime(dc as Dc, hour as Number, minute as Number, y as Number, screenWidth as Number, color as ColorType) as Number {
    var tokens = bigTimeTokens(hour, minute);
    var totalWidth = bigTimeWidth(tokens);
    var x = (screenWidth - totalWidth) / 2;

    for (var i = 0; i < tokens.size(); i++) {
        if (tokens[i] == -1) {
            drawBigColon(dc, x, y, color);
            x += COLON_W + DIGIT_GAP;
        } else {
            drawBigDigit(dc, x, y, tokens[i], color);
            x += DIGIT_W + DIGIT_GAP;
        }
    }

    return x - DIGIT_GAP;
}
