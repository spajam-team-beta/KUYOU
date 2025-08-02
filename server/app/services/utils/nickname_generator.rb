module Utils
  class NicknameGenerator
    ADJECTIVES = %w[
      迷える 悩める 恥ずかしがりの 反省中の 後悔の
      懺悔の 悔いる 内省的な 思い出したくない 黒歴史の
    ].freeze
    
    NOUNS = %w[
      子羊 旅人 求道者 悟り人 修行僧
      巡礼者 懺悔者 反省人 後悔人 黒歴史持ち
    ].freeze
    
    def self.call
      adjective = ADJECTIVES.sample
      noun = NOUNS.sample
      number = rand(1..9999).to_s.rjust(4, '0')
      
      "#{adjective}#{noun}##{number}"
    end
  end
end