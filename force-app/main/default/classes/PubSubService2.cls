/**
 * @description A simple Pub/Sub pattern implementation
 */
public with sharing class PubSubService2 {
    //Set<IHandleMessages> subscribers;
    Map<String, IHandleMessages2> subscribers;

    private PubSubService2() {
        subscribers = new Map<String, IHandleMessages2>();
    }

    /**
     * @description A singleton for service interaction.
     */
    public static PubSubService2 Instance {
        get {
            if (Instance == null) {
                Instance = new PubSubService2();
            }

            return Instance;
        }

        private set;
    }

    /**
     * @description Subscribes a given IHandleMessages implementation to the channels it returns.
     * @param implementation An instance of IHandleMessages.
     * @throws ArgumentNullException if implementation is null.
     */
    public void subscribe(IHandleMessages2 implementation) {
        ArgumentNullException.throwIfNull(implementation, 'implementation');
        if (!subscribers.containsKey(implementation.getClassName())) {
            subscribers.put(implementation.getClassName(), implementation);
        }
    }

    /**
     * @description Un-subscribes a given IHandleMessages implementation to the channels it returns.
     * @param implementation An instance of IHandleMessages.
     * @throws ArgumentNullException if implementation is null.
     */
    public void unsubscribe(IHandleMessages2 implementation) {
        ArgumentNullException.throwIfNull(implementation, 'implementation');
        if (subscribers.containsKey(implementation.getClassName())) {
            subscribers.remove(implementation.getClassName());
        }
    }

    public void emit(String channel, Object data) {
        List<Subscription__mdt> subscriptions = SubscriptionsSelector.Instance.selectByChannelAndSubscribers(channel, subscribers.keySet());

        for (Subscription__mdt subscription : subscriptions) {
            ((IHandleMessages2) (Type.forName(subscription.Subscriber__r.DeveloperName).newInstance())).handleMessage(subscription, data);
        }
    }
}