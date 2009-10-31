module FsTree
  class List
    attr_reader :root

    def initialize(path)
      @root = Directory.new(path)
    end

    def expand
      @root = Directory.new(::File.dirname(@root.path))
      reset
    end

    def slice(ix)
      if entries[ix].directory?
        @root = entries[ix]
        @root.state = :open
        @root.level = 0
        reset
      end
    end

    def toggle(ix)
      entries[ix].open? ? close(ix) : open(ix)
    end

    def open(ix)
      !!unless entries[ix].open?
        entries[ix].open
        slice = entries[ix].to_a
        entries[ix + 1, 0] = slice
        !slice.empty?
      end
    end

    def close(ix)
      !!if entries[ix].open?
        slice = entries[ix].to_a
        entries.slice!(ix + 1, slice.size)
        entries[ix].close
        !slice.empty?
      end
    end

    def [](ix)
      entries[ix]
    end

    def index(entry)
      entries.index(entry)
    end

    def each(&block)
      entries.each(&block)
    end

    def map(&block)
      entries.map(&block)
    end

    def reset
      entries, @entries = @entries, nil
      entries.each do |entry|
        ix = index(entry)
        open(ix) if ix && entry.open?
      end
      root.reset
    end

    def entries
      @entries ||= flatten(root)
    end

    def flatten(entry)
      [entry] + entry.map { |entry| flatten(entry) }.flatten
    end
  end
end
