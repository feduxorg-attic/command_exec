#encoding: utf-8

module CommandExec
  #detect errors
  class ErrorDetector

    class ContainsWithSubStringSearch

      class << self
        def check(*args,&block)
          detector = new(*args,&block)
          @found_errors = detector.search_for_errors

          binding.pry

          detector
        end
      end

      def initialize(data=[],keywords=[],exceptions=[])
        @data = data
        @keywords = keywords
        @exceptions = exceptions
        @found_errors = false
      end

      def found_errors?
        @found_errors
      end

      # Find error in data
      #
      # @param [Array,String] forbidden_word 
      #   what are the forbidden words which indidcate an error
      #
      # @param [Array,String] exception
      #  Is there any exception from that forbidden words, maybe a string
      #  which contains the forbidden word, but is no error?
      #
      # @param [Array,String] data
      #   Where to look for errors.
      #
      # @return [Boolean] Returns true if it finds an error
      def search_for_errors

        return false if @keywords.blank?
        return false if @data.blank?

        #return true  if data.find_all { |line| line[keyword] }.find_all { |line| execptions.any? { |e| line[e] } }

        @keywords.each do |word|
          @data.each do |line|
            line.strip!

            #line includes word -> error
            #exception does not include line/substring of line -> error, if
            #  includes line/substring of line -> no error
            if line.include? word and not @exceptions.any?{ |e| line[e] }
              break
            end
          end
        end

        true
      end
    end

  end

end
