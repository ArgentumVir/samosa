const DisplayWhileConnected = {
    mounted() {
        this.el.classList.add('liveview__connected--show');
    },

    disconnected () {
        this.el.classList.remove('liveview__connected--show');
        this.el.classList.add('liveview__disconnected--hide');
    },

    reconnected () {
        this.el.classList.add('liveview__connected--show');
        this.el.classList.remove('liveview__disconnected--hide');
    }
}

export default DisplayWhileConnected