import dash
from dash import dcc, html
import plotly.express as px
from pytrends.request import TrendReq
import plotly.express as px
pytrend = TrendReq()

pytrend.build_payload(kw_list=['Cold Symptoms', 'Covid Symptoms', 'Flu Symptoms'],  geo='US')

df = pytrend.interest_over_time()

df = df.reset_index()
print(df)



dash.register_page(__name__)

df = px.data.gapminder()

layout = html.Div(
    [
        dcc.Markdown('This is where py trends will be ')

    ]
)
