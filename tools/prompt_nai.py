import re
from modules import prompt_parser

re_attention = re.compile(r"""
\\\(|
\\\)|
\\\[|
\\]|
\\\\|
\\|
\(|
\[|
\{|
\<|
:([+-]?[.\d]+)\)|
\>|
\}|
\)|
]|
[^\\()\[\]:]+|
:
""", re.X) #+

def parse_prompt_attention_nai(text):
    res = []
    round_brackets = []
    square_brackets = []
    curly_brackets = [] #+

    round_bracket_multiplier = 1.1
    square_bracket_multiplier = 1 / 1.1
    curly_bracket_multiplier = 1.05 #+

    def multiply_range(start_position, multiplier):
        for p in range(start_position, len(res)):
            res[p][1] *= multiplier

    for m in re_attention.finditer(text):
        text = m.group(0)
        weight = m.group(1)

        if text.startswith('\\'):
            res.append([text[1:], 1.0])
        elif text == '(':
            round_brackets.append(len(res))
        elif text == '[':
            square_brackets.append(len(res))
        elif text == '{': #+
            curly_brackets.append(len(res)) #+
        elif weight is not None and len(round_brackets) > 0:
            multiply_range(round_brackets.pop(), float(weight))
        elif text == ')' and len(round_brackets) > 0:
            multiply_range(round_brackets.pop(), round_bracket_multiplier)
        elif text == ']' and len(square_brackets) > 0:
            multiply_range(square_brackets.pop(), square_bracket_multiplier)
        elif text == '}' and len(curly_brackets) > 0: #+
            multiply_range(curly_brackets.pop(), curly_bracket_multiplier) #+
        else:
            res.append([text, 1.0])

    for pos in round_brackets:
        multiply_range(pos, round_bracket_multiplier)

    for pos in square_brackets:
        multiply_range(pos, square_bracket_multiplier)

    for pos in curly_brackets: #+
        multiply_range(pos, curly_bracket_multiplier) #+

    if len(res) == 0:
        res = [["", 1.0]]

    # merge runs of identical weights
    i = 0
    while i + 1 < len(res):
        if res[i][1] == res[i + 1][1]:
            res[i][0] += res[i + 1][0]
            res.pop(i + 1)
        else:
            i += 1

    return res

parse_prompt_attention_original = prompt_parser.parse_prompt_attention
prompt_parser.parse_prompt_attention = parse_prompt_attention_nai
