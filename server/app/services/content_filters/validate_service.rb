module ContentFilters
  class ValidateService
    NG_WORDS = %w[
      死ね 殺す バカ アホ
    ].freeze
    
    PERSONAL_INFO_PATTERNS = [
      /\b\d{3}-\d{4}-\d{4}\b/,  # 電話番号
      /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/,  # メールアドレス
      /\b\d{3}-\d{4}\b/,  # 郵便番号
    ].freeze
    
    def self.call(content:)
      new(content: content).call
    end
    
    private
    
    def initialize(content:)
      @content = content
    end
    
    def call
      return { success: false, error: 'コンテンツが空です' } if @content.blank?
      return { success: false, error: '不適切な単語が含まれています' } if contains_ng_words?
      return { success: false, error: '個人情報が含まれている可能性があります' } if contains_personal_info?
      
      { success: true }
    end
    
    def contains_ng_words?
      NG_WORDS.any? { |word| @content.include?(word) }
    end
    
    def contains_personal_info?
      PERSONAL_INFO_PATTERNS.any? { |pattern| @content.match?(pattern) }
    end
  end
end