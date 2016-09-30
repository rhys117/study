def dms(num)
  arr = num.to_s.split('.')
  d = arr[0].to_i
  m = ((num - d) * 60).to_i
  s = ((num - d - (m.to_f / 60)) * 3600).round
  
  m += 1 if s == 60
  s = 0 if s == 60

  format(%(#{d}°%02d'%02d"), m, s)
end

puts dms(30) == %(30°00'00")
puts dms(76.73) == %(76°43'48")
puts dms(254.6) == %(254°36'00")
puts dms(93.034773) == %(93°02'05")
puts dms(0) == %(0°00'00")
puts dms(360) == %(360°00'00") || dms(360) == %(0°00'00")