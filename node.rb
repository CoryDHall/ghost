require 'yaml'

class Node
  attr_accessor :value, :parent
  def initialize(value, parent = nil)
    @value = value
    @children = {}
    @parent = parent
  end

  def [](value)
    @children[value]
  end

  def birth(value)
    node = Node.new(value)
    adopt(node)
    node
  end

  def adopt(node)
    check_node! node

    @children[node.value] = node
    node.parent = self
    self
  end

  def abandon(node)
    check_node! node

    node.parent = nil
    @children.delete node.value
  end

  def give_away(foster_parent, node)
    check_node! foster_parent
    check_node! node

    foster_parent.adopt self.abandon(node)
  end

  def search(values)
    first = values.first
    return if !first
    if has_child? first
      return @children[first] if values.count == 1
      return @children[first].search(values[1..-1])
    end
  end

  def each_child(&proc)
    children.each do |val, node|
      proc.call(val, node)
    end
  end

  def is?(value)
    self.value == value
  end

  def ==(node)
    check_node! node

    value == node.value
  end

  def ===(node)
    check_node! node
    
    self.hash == node.hash
  end

  def has_child?(value)
    !!@children[value]
  end

  def inspect
    "#{self.class}:#{self.hash} @value=#{value.inspect} @parent=#{parent && parent.value.inspect} @children=#{@children.keys}"
  end

  def to_s
    "#{value}"
  end

  def find_or_create(value)
    child = @children[value] || birth(value)
    child
  end

  def siblings
    return unless parent
    sibs = parent.children.dup
    sibs.delete value
    sibs
  end

  def descendants
    desc = []
    each_child do |_, node|
      desc << node
      desc.concat node.descendants
    end
    desc
  end

  def ancestors
    return [] unless parent
    [parent] + parent.ancestors
  end

  def to_tree
    tree = {}
    tree[value] = {}
    each_child do |val, node|
      tree[value][val] = node.sub_tree
    end
    tree
  end

  def sub_tree
    tree = {}
    each_child do |val, node|
      tree[val] = node.sub_tree
    end
    tree
  end

  def build_family(tree)
    return unless tree.is_a? Hash
    tree.each do |val, sub|
      find_or_create(val).build_family(sub)
    end
    self
  end

  def to_yaml
    to_tree.to_yaml
  end

  def self.from_tree(value, tree)
    node = Node.new(value)
    node.build_family tree
  end

  def self.from_yaml(yaml_string)
    tree = YAML::load yaml_string
    tree = tree || { "" => {} }
    value = tree.keys.first
    from_tree value, tree[value]
  end

  protected

  attr_reader :children

  private

  def check_node!(node)
    raise "#{node} is not a Node object" unless node.is_a? Node
  end
end
