var input = '';

process.stdin.on('data', function(chunk) {
  input += chunk;
});

process.stdin.on('end', function() {
  main(input);
});

var EOF = String.fromCharCode(255);

function main(input) {
  input += EOF;

  var table = createTable(input);
  var encoded = encode(input, table);
  var decoded = decode(encoded, table);

  process.stdout.write(decoded);
}

function createTable(input) {
  var symbols = {}

  input.split('').forEach(function(c) {
    symbols[c] = symbols[c] || 0;
    symbols[c]++;
  });

  var chars = Object.keys(symbols);
  var nodes = chars.map(function(c) {
    return new Node(symbols[c], c);
  }).sort(function(a, b) {
    return a.weight < b.weight ? -1 : 1;
  });

  while (nodes.length > 1) {
    var a = nodes.shift();
    var b = nodes.shift();
    var node = new Node(a.weight + b.weight);
    node.left = a;
    node.right = b;

    var insertAt;
    nodes.forEach(function(n, i) {
      insertAt = i;
      return n.weight > node.weight;
    })
    nodes.splice(insertAt, 0, node);
  }

  var tree = nodes.shift();

  var table = {};
  chars.forEach(function(c) {
    table[c] = tree.getCode(c);
  });

  return table;
}

function encode(data, table) {
  var code = data.split('').map(function(c) {
    return table[c];
  }).join('');

  code = rpad(code, Math.ceil(code.length / 8) * 8);

  var arr = code.match(/.{1,8}/g).map(function(c) {
    return parseInt(c, 2);
  });

  return new Buffer(arr);
}

function decode(buf, table) {
  var invertedTable = invert(table);

  var code = '';
  for (var i = 0, len = buf.length; i < len; i++) {
    code += lpad(buf[i].toString(2), 8);
  }

  var decoded = '';
  var bits = '';
  code.split('').some(function(bit) {
    bits += bit;
    var c = invertedTable[bits]
    if (c === EOF) return true;
    if (c) {
      decoded += c;
      bits = '';
    }
  });

  return decoded;
}

function invert(obj) {
  var inverted = {};
  Object.keys(obj).forEach(function(k) {
    inverted[obj[k]] = k;
  });
  return inverted;
}

function lpad(str, width) {
  if (str.length >= width) return str;
  return new Array(width - str.length + 1).join('0') + str;
}

function rpad(str, width) {
  if (str.length >= width) return str;
  return str + new Array(width - str.length + 1).join('0');
}

function Node(weight, symbol) {
  this.weight = weight;
  this.symbol = symbol;
  this.left = null;
  this.right = null;
}

Node.prototype.getCode = function(symbol, prefix) {
  if (this.symbol === symbol) {
    return prefix;
  }

  prefix = prefix || '';

  if (this.left) {
    var code = this.left.getCode(symbol, prefix + '0');
    if (code) return code;
  }

  if (this.right) {
    var code = this.right.getCode(symbol, prefix + '1');
    if (code) return code;
  }
};
