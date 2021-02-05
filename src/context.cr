require "./parser"

module IloToki
    record AttrResult, attr : { Array(String), Thing? }
    record TargetResult, attr : { Array(String), Thing }
    record FindResult, subject : Thing, attrs : Array({ Array(String), Thing? })

    class Context
        @props : Hash(Thing, Array({ Array(String), Thing? }))

        def initialize
            @props = {} of Thing => Array({ Array(String), Thing? })
        end

        def eval(stmt : Statement)
            query = [] of { Symbol, Thing | { Thing, Array(String) } | Array({ Array(String), Thing? }) }

            stmt.subjects.each do |subject|
                if subject.word == "seme" # Here we want to find an object matching a set of predicates
                    stmt.preds.each do |pred|
                        query << { :find, stmt.preds }
                    end
                else
                    stmt.preds.each do |pred|
                        obj, target = pred
                        if obj[0] == "seme" # Here we're looking for the value of an attribute
                            query << { :attr, subject }
                        elsif target && target.word == "seme" # And here we're looking for the direct object
                            query << { :target, { subject, obj } }
                        else
                            if @props[subject]?
                                @props[subject] << pred
                            else
                                @props[subject] = [ pred ]
                            end
                        end                
                    end
                end
            end

            res = [] of AttrResult | TargetResult | FindResult

            query.each do |check|
                case check[0]
                when :attr
                    want = check[1].as Thing
                    if @props[want]?
                        @props[want].each do |prop| # Get every property of the requested object
                            res << AttrResult.new prop
                        end
                    else
                        STDERR.puts %(sona ala tan "#{want.word}#{want.adj.size > 0 ? " " + want.adj.join : ""}")
                    end
                when :target
                    check2, want = check[1].as { Thing, Array(String) }
                    if @props[check2]? # Find the target of the requested property
                        @props[check2].each do |prop|
                            if prop[0] == want
                                obj, target = prop
                                target = target.as Thing
                                val = { obj, target }
                                res << TargetResult.new val
                            end                     
                        end
                    else
                        STDERR.puts %(sona ala tan "#{check2.word}#{check2.adj.size > 0 ? " " + check2.adj.join : ""}")
                    end
                when :find
                    want = check[1].as Array({ Array(String), Thing? })

                    want.each do |check|
                        @props.each do |key, val| # Find all objects with the requested property
                            if val.includes? check
                                res << FindResult.new key, val
                            end
                        end
                    end
                end
            end

            res
        end
    end
end
