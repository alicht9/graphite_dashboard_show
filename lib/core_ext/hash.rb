class Hash
  def symbolize_keys!
    self.inject({}) {|h, (k, v)| h.merge({ k.to_sym => v})}
  end
  def symbolize_keys
    self.dup.symbolize_keys!
  end
end
