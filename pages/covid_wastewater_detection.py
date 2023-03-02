import dash
from dash import dcc, html
import plotly.express as px

dash.register_page(__name__)


layout = html.Div(
    [
        dcc.Markdown('This is where the deep learning will be ') # just a template layout
    ]
)
