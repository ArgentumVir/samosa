const DisplayWhileDisconnected = {
    mounted() {
        this.el.classList.add('liveview__connected--hide');
    },

    disconnected () {
        this.el.classList.remove('liveview__connected--hide');
        this.el.classList.add('liveview__disconnected--show');
    },

    reconnected () {
        this.el.classList.add('liveview__connected--hide');
        this.el.classList.remove('liveview__disconnected--show');
    }
}

export default DisplayWhileDisconnected