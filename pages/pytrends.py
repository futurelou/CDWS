import dash
from dash import dcc, html
import plotly.express as px

dash.register_page(__name__)

df = px.data.gapminder()

layout = html.Div(
    [
        dcc.Markdown('This is where py trends will be ')
    ]
)
