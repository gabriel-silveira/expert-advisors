<chart>
id=132321209796011859
symbol=WDOK20
description=DOLAR MINI
period_type=0
period_size=1
digits=3
tick_size=0.500000
position_time=1587636600
scale_fix=0
scale_fixed_min=5431.000000
scale_fixed_max=5470.500000
scale_fix11=0
scale_bar=0
scale_bar_val=1.000000
scale=32
mode=1
fore=0
grid=1
volume=0
scroll=1
shift=0
shift_size=20.862397
fixed_pos=0.000000
ohlc=0
one_click=0
one_click_btn=1
bidline=1
askline=0
lastline=0
days=1
descriptions=0
tradelines=0
window_left=26
window_top=26
window_right=1507
window_bottom=409
window_type=3
floating=0
floating_left=0
floating_top=0
floating_right=0
floating_bottom=0
floating_type=1
floating_toolbar=1
floating_tbstate=
background_color=0
foreground_color=16777215
barup_color=65280
bardown_color=65280
bullcandle_color=0
bearcandle_color=16777215
chartline_color=65280
volumes_color=3329330
grid_color=10061943
bidline_color=10061943
askline_color=255
lastline_color=49152
stops_color=255
windows_total=1

<expert>
name=Marobot
path=Experts\GS\Marobot.ex5
expertmode=33
<inputs>
num_lots=10
TP=13500
SL=9000
marobozuHeight=2.5
</inputs>
</expert>

<window>
height=100.000000
objects=10

<indicator>
name=Main
path=
apply=1
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=0
fixed_height=-1
</indicator>

<indicator>
name=Custom Indicator
path=Indicators\CodeTrading_PrincipeNY_Cohen.ex5
apply=0
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=0
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=0.000000
expertmode=32
fixed_height=-1

<graph>
name=PrincipeNY
draw=0
style=0
width=1
arrow=251
color=
</graph>

<graph>
name=PrincipeNY
draw=0
style=0
width=1
arrow=251
color=
</graph>

<graph>
name=PrincipeNY
draw=0
style=0
width=1
arrow=251
color=
</graph>

<graph>
name=Sinal Compra
draw=0
style=0
width=1
arrow=251
color=
</graph>

<graph>
name=Sinal Venda
draw=0
style=0
width=1
arrow=251
color=
</graph>

<graph>
name=PrincipeNY-Candles
draw=17
style=0
width=1
arrow=251
color=17919,65280,14804223,9419919
</graph>
<inputs>
InpBandsPeriod=30
InpBandsDeviations=2.2
</inputs>
</indicator>
<object>
type=31
name=autotrade #248966726 buy 1 WDOK20 at 5406.500
hidden=1
color=11296515
selectable=0
date1=1587566345
value1=5406.500000
</object>

<object>
type=32
name=autotrade #249025525 sell 1 WDOK20 at 5392.000
hidden=1
color=1918177
selectable=0
date1=1587569847
value1=5392.000000
</object>

<object>
type=32
name=autotrade #249025769 sell 1 WDOK20 at 5394.500
hidden=1
color=1918177
selectable=0
date1=1587569852
value1=5394.500000
</object>

<object>
type=31
name=autotrade #249027638 buy 1 WDOK20 at 5391.500
hidden=1
descr=[sl 5391.500]
color=11296515
selectable=0
date1=1587569883
value1=5391.500000
</object>

<object>
type=2
name=autotrade #248966726 -> #249025525 WDOK20
hidden=1
descr=5406.500 -> 5392.000
color=11296515
style=2
selectable=0
ray1=0
ray2=0
date1=1587566345
date2=1587569847
value1=5406.500000
value2=5392.000000
</object>

<object>
type=2
name=autotrade #249025769 -> #249027638 WDOK20
hidden=1
descr=5394.500 -> 5391.500
color=1918177
style=2
selectable=0
ray1=0
ray2=0
date1=1587569852
date2=1587569883
value1=5394.500000
value2=5391.500000
</object>

<object>
type=31
name=autotrade #249288286 buy 10 WDOK20 at 5442.000
hidden=1
color=11296515
selectable=0
date1=1587637862
value1=5442.000000
</object>

<object>
type=32
name=autotrade #249299753 sell 10 WDOK20 at 5433.000
hidden=1
descr=[sl 5433.000]
color=1918177
selectable=0
date1=1587638143
value1=5433.000000
</object>

<object>
type=2
name=autotrade #249288286 -> #249299753
hidden=1
descr=5442.000 -> 5433.000
color=11296515
style=2
selectable=0
ray1=0
ray2=0
date1=1587637862
date2=1587638143
value1=5442.000000
value2=5433.000000
</object>

<object>
type=2
name=autotrade #249288286 -> #249299753 WDOK20
hidden=1
descr=5442.000 -> 5433.000
color=11296515
style=2
selectable=0
ray1=0
ray2=0
date1=1587637862
date2=1587638143
value1=5442.000000
value2=5433.000000
</object>

</window>
</chart>