class Array
  if !respond_to?(:pluck) 
    def pluck(&blk)
      i = 0
      while i < length
        return self[i] if blk.call(self[i])
        i += 1
      end
    end
  end
end