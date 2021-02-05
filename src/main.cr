require "./parser"
require "./context"

parser = IloToki::Parser.new
ctx    = IloToki::Context.new

loop do
    STDOUT << "<- "
    query = gets
    unless query
        exit 1
    end
    
    parsed = parser.parse query
    if parsed 
        result = ctx.eval parsed
    
        if result
            result.each do |part|
                puts(String.build do |s|
                    case part
                    when IloToki::AttrResult
                        parsed.subjects.each do |subject|
                            s << " -> "
                            s << subject.word
                            if subject.adj.size > 0
                                s << " "
                                s << subject.adj.join
                            end
                        end
                        s << " li "
                        s << part.attr[0].join
                        target = part.attr[1]
                        if target
                            s << " e "
                            s << target.word
                            s << " "
                            s << target.adj.join
                        end
                    when IloToki::TargetResult
                        parsed.subjects.each do |subject|
                            s << " -> "
                            s << subject.word
                            if subject.adj.size > 0
                                s << " "
                                s << subject.adj.join
                            end
                        end
                        s << " li "
                        s << part.attr[0].join
                        s << " e "
                        s << part.attr[1].word
                        s << " "
                        s << part.attr[1].adj.join
                    when IloToki::FindResult
                        s << " -> #{part.subject.word}"
                        if part.subject.adj.size > 0
                            s << " "
                            s << part.subject.adj.join
                        end

                        part.attrs.each do |attr|
                            s << " li "
                            s << attr[0].join
                            obj = attr[1]
                            if obj
                                s << " e "
                                s << obj.word
                                s << " "
                                s << obj.adj.join
                            end
                        end
                    end
                end)
            end
        end
    end
end
