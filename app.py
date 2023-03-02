import dash
from dash import html,dcc

app = dash.Dash(__name__, use_pages=True)

app.layout = html.Div(
    [
        html.Div(" Welcome To CDWS", style={'fontSize':50, 'textAlign':'center'}),
        html.Div([
            dcc.Link(page['name'] + " | ", href= page['path'])
            for page in dash.page_registry.values()
        ]),
        html.Hr(),
        dash.page_container
    ]
)

if __name__ == '__main__':
    app.run(debug=True)