/**
 * @description An implementation of IHandleMessages which validates the passed in Lead and inserts it.
 */
public with sharing class IncomingLeadHandler implements IHandleMessages {
    @testVisible
    private static final String INCOMING_LEAD_CHANNEL = 'IncomingLeads';
    @testVisible
    private static final String INVALID_LEAD_ERROR = 'The Lead specified is invalid.';
    @testVisible
    private static final String CHANNEL_PARAM = 'channel';
    private static final String LEAD_FIRSTNAME_PARAM = 'Lead.FirstName';
    private static final String UNEXPECTED_ERROR = 'Unexpected error: {0} - Line: {1}';
    public Map<String, List<Subscription__mdt>> subscriptions { get; private set; }

    /**
     * @description Constructs an instance of IncomingLeadHandler.
     */
    public IncomingLeadHandler() {
        loadSubscriptions(IncomingLeadHandler.class.getName());
    }

    public void loadSubscriptions(String className) {
        subscriptions = new Map<String, List<Subscription__mdt>>();
        List<Subscription__mdt> subs = [
            SELECT Id, Channel__c, ChannelHandlerClassName__c
            FROM Subscription__mdt
            WHERE Subscriber__c = :className
            ORDER BY ExecutionOrder__c
        ];
        for (Subscription__mdt sub : subs) {
            if (!subscriptions.containsKey(sub.Channel__c)) {
                subscriptions.put(sub.Channel__c, new List<Subscription__mdt>());
            }
            subscriptions.get(sub.Channel__c).add(sub);
        }
    }

    /**
     * @description Handles a message on a subscribed channel.
     * @param channel The channel emitting the message.
     * @param data The accompanying data for the message.
     * @throws ArgumentNullException if channel is null.
     * @throws ArgumentException if the lead is missing a FirstName.
     */
    public void handleMessage(String channel, Object data) {
        ArgumentNullException.throwIfNull(channel, CHANNEL_PARAM);

        handleChannels(channel, data);
    }

    void handleChannels(String channel, Object data) {
        if (channel.equals(INCOMING_LEAD_CHANNEL)) {
            handleIncomingLeadChannel(data);
        }
    }

    void handleIncomingLeadChannel(Object data) {
        handleExceptions(data);
        handleIncomingLeadChannel((Lead) data);
    }

    void handleExceptions(Object data) {
        try {
            Lead record = (Lead) data;
            handleFirstNameException(record.FirstName);
        } catch (TypeException te) {
            throw new ArgumentException(INVALID_LEAD_ERROR); //data is not a Lead
        }
    }

    void handleFirstNameException(String value) {
        try {
            ArgumentNullException.throwIfNull(value, LEAD_FIRSTNAME_PARAM);
        } catch (ArgumentNullException e) {
            throw new ArgumentException(INVALID_LEAD_ERROR);
        }
    }

    void handleIncomingLeadChannel(Lead record) {
        Database.insert(record);
    }

    /**
     * @description Gets a list of channels an implementation subscribes to.
     * @return A List<String> of channel names this implementation is subscribed to.
     */
    public List<String> getSubscribedChannels() {
        return new List<String>{ INCOMING_LEAD_CHANNEL };
    }


    public void handleMessage2(String channel, Object data) {
        List<Subscription__mdt> subsChannel = subscriptions.get(channel);
        for (Subscription__mdt subChannel : subsChannel) {
            ((IChannelHandler) Type.forName(subChannel.ChannelHandlerClassName__c).newInstance()).handleMessage(data);
        }
    }
}