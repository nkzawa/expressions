#ifndef HUFFMAN_CODING_H_
#define HUFFMAN_CODING_H_

#include <map>

using namespace std;

const unsigned char eof = 255;

void read_stdin(string &in);

void create_table(const string &input, map<unsigned char, string> &table);

void encode(string &data, map<unsigned char, string> &table, vector<unsigned char> &encoded);

void decode(vector<unsigned char> &data, map<unsigned char, string> &table, string &decoded);

void rpad(string &s, int width);

void lpad(string &s, int width);

string itos(int i, int base = 10);

class Node {
  public:
    const int weight;
    virtual void generate_codes(map<unsigned char, string> &table, string prefix = "") = 0;
    virtual ~Node() {}

  protected:
    Node(int weight): weight(weight) {}
};

class LeafNode : public Node {
  public:
    const unsigned char symbol;

    LeafNode(int weight, unsigned char symbol): Node(weight), symbol(symbol) {}
    void generate_codes(map<unsigned char, string> &table, string prefix = "");
};

class InternalNode : public Node {
  public:
    Node* const left;
    Node* const right;

    InternalNode(Node* left, Node* right): Node(left->weight + right->weight), left(left), right(right) {}
    ~InternalNode() {
      delete this->left;
      delete this->right;
    }
    void generate_codes(map<unsigned char, string> &table, string prefix = "");
};

struct GreaterWeight;

#endif
