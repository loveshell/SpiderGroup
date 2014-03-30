# encoding: utf-8


=begin
@replace = [{:type=>'delete_to_end', :from=>'aaaa', :to=>'', :from1=>''}]

type的定义
  replace_to_end 表示从aaaa开始替换后面所有的字符串
  replace_to_position 表示从起始位置开始替换字符串，直到aaaa开始的位置
  string_replace 替换
  replace_between 表示替换from到from1中间的字符串
=end

module ReplaceParser
=begin
  def replace_by_type!(replace_list, str)
    replace_list.each{|r|
      case r[:type]
        when "replace_to_end"
          str[str.index(r[:from])..str.size-1]  = r[:to] if str.index(r[:from])
        when "replace_to_position"
          str[0..str.index(r[:from])-1] = r[:to] if str.index(r[:from])
        when "string_replace"
          str[r[:from]] = r[:to] if str.index(r[:from])
        else
      end
    }
    str
  end
=end

  def replace_by_type(replace_list, rawstr)
    str = rawstr.dup()
    replace_list.each{|r|
      if r[:from] and r[:from].size>0
        case r[:type]
          when "replace_to_end"
            str[str.index(r[:from])..str.size-1]  = r[:to] if str.index(r[:from])
          when "replace_to_position"
            str[0..str.index(r[:from])-1] = r[:to] if str.index(r[:from])
          when "string_replace"
            while str.index(r[:from])
              str[r[:from]] = r[:to]
              break unless r[:repead]
            end

          when "replace_between"
            str.gsub!(/#{Regexp.escape(r[:from])}(.*?)#{Regexp.escape(r[:from1])}/m, r[:to])
          else
        end
      end
    }

    str
  end
end

class String
  def string_between_markers marker1, marker2
    self[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
  end
end
