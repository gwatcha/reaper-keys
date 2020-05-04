# frozen_string_literal: true

module KeyDefinitions
  CONTEXTS = Hash[
    midi: 32_060,
    main: 0
  ]
  KEY_MODS = Hash[
    # C -> ctrl, M -> alt, S -> shift
    C: 9,
    M: 17,
    S: 5,
    MS: 21,
    CS: 13,
    CM: 25,
    CMS: 29,
  ]
  # these key codes clash with others when modifiers are on, reaper solves the problem by by decrementing the key_mod_id
  MOD_DECREMENTED_KEYS = ["'", '%', '&', '(', '!', '{',
                          '}', '|', '.', '!', '#', '$',
                          ',', '-', '"', '>', '<', '+', ';'].freeze
  ALIASES = Hash[
    '.' => 'period',
    ':' => 'colon',
    ',' => 'comma',
    '-' => 'hyphen',
    '_' => 'underscore',
    ';' => 'semicolon',
    '?' => 'questionmark',
    '+' => 'plus',
    '!' => 'exclamation',
    "'" => 'apostrophe',
    '\\' => 'backslash',
    '|' => 'pipe',
    '/' => 'slash',
    '#' => 'numbersign',
    '@' => 'at',
    '§' => 'sectionsign',
    '~' => 'tilde',
    '±' => 'plusminus',
    ']' => 'closebracket',
    '[' => 'openbracket',
    '(' => 'openparen',
    ')' => 'closeparen',
    '$' => 'dollar',
    '%' => 'percent',
    '&' => 'ampersand',
    '"' => 'quotation',
    '}' => 'closewing',
    '{' => 'openwing',
    '=' => 'equals',
    '`' => 'backtick',
  ]
  KEY_TABLE = Hash[
    special: Hash[
      key_type_id: 1,
      keys: Hash[
        '<left>' => 37,
        '<up>' => 38,
        '<right>' => 39,
        '<down>' => 40,
        '<F1>' => 112,
        '<F2>' => 113,
        '<F3>' => 114,
        '<F4>' => 115,
        '<F5>' => 116,
        '<F6>' => 117,
        '<F7>' => 118,
        '<F8>' => 119,
        '<F9>' => 120,
        '<F10>' => 121,
        '<backspace>' => 8,
        '<SPC>' => 32,
        '<TAB>' => 9,
        '<ESC>' => 27,
      ]
    ],
    letters: Hash[
      key_type_id: 1,
      keys: Hash[
        'a' => 65,
        'b' => 66,
        'c' => 67,
        'd' => 68,
        'e' => 69,
        'f' => 70,
        'g' => 71,
        'h' => 72,
        'i' => 73,
        'j' => 74,
        'k' => 75,
        'l' => 76,
        'm' => 77,
        'n' => 78,
        'o' => 79,
        'p' => 80,
        'q' => 81,
        'r' => 82,
        's' => 83,
        't' => 84,
        'u' => 85,
        'v' => 86,
        'w' => 87,
        'x' => 88,
        'y' => 89,
        'z' => 90,
      ]
    ],
    shifted: Hash[
      key_type_id: 0,
      keys: Hash[
        '"' => 34,
        '|' => 124,
        '!' => 33,
        '<' => 60,
        '>' => 62,
        '_' => 95,
        ':' => 58,
        '#' => 35,
        '@' => 64,
        '}' => 125,
        '{' => 123,
        '(' => 40,
        ')' => 41,
        '+' => 43,
        '$' => 36,
        '%' => 37,
        '&' => 38,
        '?' => 63,
        '~' => 126,
      ]
    ],
    numbers: Hash[
      key_type_id: 1,
      keys: Hash[
        '0' => 48,
        '1' => 49,
        '2' => 50,
        '3' => 51,
        '4' => 52,
        '5' => 53,
        '6' => 54,
        '7' => 55,
        '8' => 56,
        '9' => 57
      ]
    ],
    normal: Hash[
      key_type_id: 0,
      keys: Hash[
        '<return>' => 13,
        "'" => 39,
        '.' => 46,
        ',' => 44,
        '-' => 45,
        ';' => 59,
        '\\' => 92,
        '/' => 47,
        '§' => 167,
        '±' => 177,
        ']' => 93,
        '[' => 91,
        '=' => 61,
        '`' => 96,
      ]
    ]
  ]
end
