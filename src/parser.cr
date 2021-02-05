module IloToki
    VALID = [ # All valid words
        #"a",
        "akesi",
        "ala",
        "alasa",
        "ali",
        "anpa",
        "ante",
        "anu",
        "awen",
        "e",
        "en",
        "esun",
        "ijo",
        "ike",
        "ilo",
        "insa",
        "jaki",
        "jan",
        "jelo",
        "jo",
        "kala",
        "kalama",
        "kama",
        "kasi",
        "ken",
        "kepeken",
        "kili",
        "kiwen",
        "ko",
        "kon",
        "kule",
        "kulupu",
        "kute",
        #"la",
        "lape",
        "laso",
        "lawa",
        "len",
        "lete",
        "li",
        "lili",
        "linja",
        "lipu",
        "loje",
        "lon",
        "luka",
        "oko",
        "lupa",
        "ma",
        "mama",
        "mani",
        "meli",
        "mi",
        "mije",
        "moku",
        "moli",
        "monsi",
        "mu",
        "mun",
        "musi",
        "mute",
        "namako",
        "nanpa",
        "nasa",
        "nasin",
        "nena",
        "ni",
        "nimi",
        "noka",
        #"o",
        "oko",
        "olin",
        "ona",
        "open",
        "pakala",
        "pali",
        "palisa",
        "pan",
        "pana",
        "pi",
        "pilin",
        "pimeja",
        "pini",
        "pipi",
        "poka",
        "poki",
        "pona",
        "pu",
        "sama",
        "seli",
        "selo",
        "seme",
        "sewi",
        "sijelo",
        "sike",
        "namako",
        "sina",
        "sinpin",
        "sitelen",
        "sona",
        "soweli",
        "suli",
        "suno",
        "supa",
        "suwi",
        "tan",
        "taso",
        "tawa",
        "telo",
        "tenpo",
        "toki",
        "tomo",
        "tu",
        "unpa",
        "uta",
        "utala",
        "walo",
        "wan",
        "waso",
        "wawa",
        "weka",
        "wile",
        "kin"
    ]

    record Thing, word : String, adj : Array(String) do
        def ==(other : Thing)
            return other.word == word && other.adj == adj
        end
    end
    record Statement, subjects : Array(Thing),  preds : Array({ Array(String), Thing? })

    class Parser
        def initialize
        end

        def parse(text : String)
            pos   = 0
            words = [] of String
            built = ""

            while pos < text.size # Lexing
                char = text[pos]
                case char
                when ' '
                    if VALID.includes? built
                        words << built
                        built = ""
                    else
                        STDERR.puts(String.build do |s|
                            s.puts text
                            s.puts (" " * (pos - built.size)) + '^'
                            s.puts %(nimi ike "#{built}")
                        end)               
                        return nil
                    end
                else
                    built += char
                end

                pos += 1
            end
            if VALID.includes? built # Add any leftover words
                words << built
            else
                STDERR.puts(String.build do |s|
                    s.puts text
                    s.puts (" " * (pos - built.size)) + '^'
                    s.puts %(nimi ike "#{built}")
                end)               
                return nil
            end

            subject_words = [] of String # Geting the subject(s)
            subjects = [] of Thing
            loop do
                if words.size == 0
                    STDERR.puts "pini toki pi sona ala"
                    return nil
                end
                word = words.shift
                case word
                when "li" # Subjects end on the word li
                    words.insert 0, word
                    break
                when "en" # An en signifies a seperator between two subjects
                    subjects << Thing.new subject_words[0], subject_words[1..]
                    subject_words = [] of String
                else
                    subject_words << word
                end
            end
            subjects << Thing.new subject_words[0], subject_words[1..]

            preds = [] of { Array(String), Thing? }
            unless words[0] == "li" # We NEED a li
                STDERR.puts %("li" ala lon nimi mute)
                return nil
            end
            words.shift # Remove li

            loop do # Get predicates
                pred = [] of String
                loop do
                    if words.size == 0
                        STDERR.puts "pini toki pi sona ala"
                        return nil
                    end
                    word = words.shift
                    if word == "li" || word == "e" # li or e signifies the end of a verb/noun/etc.
                        words.insert 0, word
                        break
                    else
                        pred << word
                    end

                    break unless words.size > 0
                end

                if words[0]? == "e" # Check for direct object
                    words.shift
                    obj_words = [] of String
                    loop do
                        word = words.shift
                        if word == "li" # li ends a direct object
                            words.insert 0, word
                            break
                        else
                            obj_words << word
                        end

                        break unless words.size > 0
                    end
                    obj = Thing.new obj_words[0], obj_words[1..]
                end

                preds << { pred, obj }

                break unless words[0]? == "li" # Quit unless we have more predicates
                words.shift
            end

            return Statement.new subjects, preds # All done
        end
    end
end
