public abstract class HandleMessages implements IHandleMessages2 {
    String className;

    public HandleMessages(String className) {
        this.className = className;
    }

    protected void handleMessage(String channelHandlerClassName, Object data) {
        ((IChannelHandler) Type.forName(channelHandlerClassName).newInstance()).handleMessage(data);
    }

    public String getClassName() {
        return className;
    }
}
