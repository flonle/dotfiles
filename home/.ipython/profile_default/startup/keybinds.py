from IPython import get_ipython

# Bind Ctrl+e to open_in_editor
ip = get_ipython()
if ip and hasattr(ip, 'pt_app') and ip.pt_app:
    @ip.pt_app.key_bindings.add('c-e')
    def open_in_editor(event):
        event.app.current_buffer.open_in_editor()
