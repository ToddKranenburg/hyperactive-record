class AttrObject
  def self.my_attr_reader(*cols)
    cols.each do |col_name|
      self.getter(col_name)
    end
  end

  def self.my_attr_writer(*cols)
    cols.each do |col_name|
      self.setter(col_name)
    end
  end

  def self.my_attr_accessor(*cols)
    cols.each do |col_name|
      self.getter(col_name)
      self.setter(col_name)
    end
  end

  def self.setter(col_name)
    define_method("#{col_name}=") do |val|
      instance_variable_set("@#{col_name}", val)
    end
  end

  def self.getter(col_name)
    define_method(col_name) do
      instance_variable_get("@#{col_name}")
    end
  end
end
