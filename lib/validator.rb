require 'sql_base'
class Validator
  def validates (*cols, options)
    cols.each do |col|
      if options[:presence]
        return false if !present?(col)
        # raise "#{col} not present" if !present?(col)
      end
      if options[:length]
        return false if !length?(col, options[:length])
        # raise "#{col} does not meet length criteria" if !length?(col, options[:length])
      end
    end

    return true
  end

  def present?(col)
    self.respond_to?(col.to_sym)
  end

  def length?(col, options)
    min = options[:minimum]
    max = options[:maximum]

    if (min)
      return false if self.send(col).length < min
    end
    if (max)
      return false if self.send(col).length > max
    end

    true
  end
end
