if hash supervisor 2>/dev/null; then
    supervisor ./app.js
else
    node ./app.js lan
fi
