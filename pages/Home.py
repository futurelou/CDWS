import dash
from dash import dcc, html
import plotly.express as px

dash.register_page(__name__, path='/') # this is the home page

df = px.data.gapminder()

layout = html.Div(
    [
        dcc.Dropdown([x for x in df.continent.unique()], id = 'cont-choice') # just a template layout
    ]
)
