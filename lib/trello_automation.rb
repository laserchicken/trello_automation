# -*- coding: utf-8 -*-
require 'trello_automation/board_duplicator'

class TrelloAutomation
  def start(arg)
    case arg[0]
    when nil
      puts "You must specify at least one argument!"
    when 'authorize'
      Authorization.authorize
      puts "Authorization successful, you can use the script now."
    when 'copy'
      puts "\nCreating board copy..."
      board_duplicator = BoardDuplicator.new
      board_duplicator.call(arg[1])
    when 'clone'
      if arg[2].nil?
        puts "You didn't specify members the clones should be made for. " \
        "Perhaps you wanted to 'copy' rather than 'clone'?"
        return
      elsif arg[3] == 'subscribe'
        BoardDuplicator.subscription_list(arg.slice(4..(arg.length-1)))
      end
      board_duplicator = BoardDuplicator.new
      board_url = arg[1]
      members_list_path = arg[2]
      if members_names = names(members_list_path)
        members_names.each do |full_member_name, trello_nickname|
          board_duplicator.call(board_url,
                                trello_nickname: trello_nickname,
                                full_member_name: full_member_name)
        end
      end
    when 'close_all_but'
      board_duplicator = BoardDuplicator.new
      arg[1].nil? ? filter = 'starred' : filter = argumentize(arg, 1)
      board_duplicator.close_boards(filter)
    when 'show'
      board_duplicator = BoardDuplicator.new
      filter = arg[1] || 'open'
      arg[2].nil? ? fields = 'name' : fields = argumentize(arg, 2)
      puts board_duplicator.show(filter, fields)
    end
  end

  private

  def names(members_list_path)
    return false if members_list_path.nil?
    names = []
    File.open(members_list_path, encoding: 'utf-8').each do |line|
      /^(?<full_member_name>.*)<(?<trello_nickname>.*)>$/ =~ line
      names << [full_member_name, trello_nickname]
    end
    # p names #> [["John Doe ", "johnny"], ["Lorem Ipsum ", "cicero"]]
    names
  end

  def argumentize(input, starting_point)
    input.slice(starting_point..(input.length-1)).to_s[1..-2].delete('"').delete(' ')
  end
end
