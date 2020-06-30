<chart>
id=132379371569144498
symbol=WDON20
description=DOLAR MINI
period_type=0
period_size=5
digits=3
tick_size=0.500000
position_time=0
scale_fix=0
scale_fixed_min=5377.500000
scale_fixed_max=5489.500000
scale_fix11=0
scale_bar=0
scale_bar_val=1.000000
scale=16
mode=1
fore=0
grid=1
volume=0
scroll=1
shift=0
shift_size=19.827586
fixed_pos=0.000000
ticker=1
ohlc=0
one_click=0
one_click_btn=1
bidline=1
askline=0
lastline=1
days=1
descriptions=0
tradelines=1
tradehistory=1
window_left=0
window_top=0
window_right=0
window_bottom=0
window_type=1
floating=0
floating_left=0
floating_top=0
floating_right=0
floating_bottom=0
floating_type=1
floating_toolbar=1
floating_tbstate=
background_color=921867
foreground_color=11318692
barup_color=7902046
bardown_color=4939831
bullcandle_color=6782544
bearcandle_color=3820075
chartline_color=7902046
volumes_color=3329330
grid_color=2106906
bidline_color=10061943
askline_color=255
lastline_color=49152
stops_color=255
windows_total=2

<window>
height=116.328044
objects=0

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
name=Moving Average
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

<graph>
name=
draw=129
style=0
width=2
arrow=251
color=8421376
</graph>
period=34
method=0
</indicator>

<indicator>
name=Custom Indicator
path=Indicators\Examples\ZigZag.ex5
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
expertmode=0
fixed_height=-1

<graph>
name=ZigZag(6,5,3)
draw=4
style=0
width=1
color=8421376
</graph>
<inputs>
InpDepth=6
InpDeviation=5
InpBackstep=3
</inputs>
</indicator>
</window>

<window>
height=33.671956
objects=0

<indicator>
name=Volumes
path=
apply=0
show_data=1
scale_inherit=0
scale_line=0
scale_line_percent=50
scale_line_value=0.000000
scale_fix_min=1
scale_fix_min_val=0.000000
scale_fix_max=0
scale_fix_max_val=37364.280000
expertmode=0
fixed_height=-1

<graph>
name=
draw=11
style=0
width=5
arrow=251
color=6782544,3820075
</graph>
real_volumes=0
</indicator>
</window>
</chart>