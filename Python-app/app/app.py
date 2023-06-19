from flask import Flask, render_template, request

app = Flask(__name__)

@app.route('/', methods=['GET', 'POST'])
def order_form():
    if request.method == 'POST':
        items = request.form.getlist('item')
        quantities = request.form.getlist('quantity')
        order = zip(items, quantities)
        return render_template('order_summary.html', order=order)
    return render_template('order_form.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
