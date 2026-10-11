from fastapi import FastAPI
from fastapi.responses import HTMLResponse, RedirectResponse

app = FastAPI(docs_url=None, redoc_url=None, openapi_url=None)


def read_file(name: str) -> str:
    with open(name, encoding="utf-8") as f:
        return f.read()


@app.get("/", response_class=RedirectResponse)
def root():
    return RedirectResponse(url="/en")


@app.get("/en", response_class=HTMLResponse)
def resume_en():
    return read_file("resume_en.html")


@app.get("/ru", response_class=HTMLResponse)
def resume_ru():
    return read_file("resume_ru.html")
