#!/usr/bin/ruby
require 'optparse'

# seeds: array of unique numbers from 0..99
# length: length of the number string to generate
def gen_numstr(seeds, length)
    ((length/2) + 1).times.map{
        seeds.sample.to_s.rjust(2, "0")
    }.join[0..length-1]
end

def tcols
    `tput cols`.to_i
end

def sec_left(finish)
    ((finish + 1) - Time.now).to_i
end

def clear
    print "\e[H\e[2J"
end

def display(string)
    clear
    puts string
end

def log_stat(memorizee, answer, setting, log_path = "results.txt")
    stat = [
        ["date"     , Time.now],
        ["rule"     , setting[:rule]],
        ["time"     , setting[:time]],
        ["seed"     , setting[:seed]],
        ["length"   , setting[:length]],
        ["memorizee", memorizee],
        ["answer"   , answer],
        ["result"   , memorizee == answer ? "correct" : "wrong"]
    ]

    no_label = !File.exist?(log_path) || File.stat(log_path).size == 0

    File.open(log_path, "a") do |f|
        f.puts(stat.map(&:first).join(",")) if no_label
        f.puts(stat.map(&:last).map(&:to_s).join(","))
    end
end

def flash_main(memorizee, time)
    finish = Time.now + time

    while(true)
        t = Time.now
        left = sec_left(finish)
        break if left <= 0

        buf = [
            "",
            memorizee,
            "",
            left <= 5 ? left.to_s : "",
        ]

        display(buf.map{|l| l.center(tcols) }.join("\n"))

        sleep 1 - (Time.now - t)
    end
end

def call_main(memorizee, time)
    num_left = memorizee.chars

    while(num_left.length > 0)
        t = Time.now
        num = num_left.shift

        buf = [
            "",
            num,
        ]

        clear
        sleep 0.1
        display(buf.map{|l| l.center(tcols) }.join("\n"))

        sleep time - (Time.now - t)
    end
end

opts = ARGV.getopts("r:t:s:l:")

setting = {
    rule:   opts["r"] == "call" ? :call : :flash,
    time:   opts["t"] ? opts["t"].to_f  : 20,
    seed:   opts["s"] ? opts["s"].to_i  : 99,
    length: opts["l"] ? opts["l"].to_i  : 20,
}

seeds = (0..setting[:seed]).to_a

while(true)
    print "Hit Enter to start or Ctrl+C to exit."
    gets

    memorizee = gen_numstr(seeds, setting[:length])

    if setting[:rule] == :flash
        flash_main(memorizee, setting[:time])
    else
        call_main(memorizee, setting[:time])
    end

    clear
    print "Recall   : "
    answer = gets.chomp
    puts "Memorizee: #{memorizee}"
    puts answer == memorizee ? "Correct!" : "Wrong..."

    log_stat(memorizee, answer, setting)
end
