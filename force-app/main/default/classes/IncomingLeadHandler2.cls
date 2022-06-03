public with sharing class IncomingLeadHandler2 extends HandleMessages {   
    public IncomingLeadHandler2() {
        super(IncomingLeadHandler2.class.getName());
    }

    public void handleMessage(Subscription__mdt subscription, Object data) {
        handleMessage(subscription.ChannelHandlerClassName__r.DeveloperName, data);
    }
}