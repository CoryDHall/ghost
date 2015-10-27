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
    @children[node.value] = node
    node.parent = self
    self
  end

  def abandon(node)
    node.parent = nil
    @children.delete node.value
  end

  def give_away(foster_parent, node)
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

  def is?(value)
    self.value == value
  end

  def ==(node)
    value == node.value
  end

  def ===(node)
    self.hash == node.hash
  end

  def has_child?(value)
    !!@children[value]
  end

  def inspect
    "#{self.class}:#{self.hash} @value=#{value.inspect} @parent=#{parent && parent.value.inspect} @children=#{@children.keys}"
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

  def to_tree
    tree = {}
    tree[value] = {}
    children.each do |val, node|
      tree[value][val] = node.sub_tree
    end
    tree
  end

  def sub_tree
    tree = {}
    children.each do |val, node|
      tree[val] = node.sub_tree
    end
    tree
  end

  def build_family(tree)
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
end
