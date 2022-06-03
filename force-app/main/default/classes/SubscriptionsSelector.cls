public with sharing class SubscriptionsSelector {
    public static SubscriptionsSelector Instance {
        get {
            if (Instance == null) {
                Instance = new SubscriptionsSelector();
            }

            return Instance;
        }
        private set;
    }

    public List<Subscription__mdt> selectByChannelAndSubscribers(String channel, Set<String> subscribersName) {
        System.debug('channel: ' + channel);
        System.debug('subscribersName: ' + subscribersName);
        return [
            SELECT Id, Channel__r.DeveloperName, ChannelHandlerClassName__r.DeveloperName, Subscriber__r.DeveloperName
            FROM Subscription__mdt
            WHERE Channel__r.DeveloperName = :channel AND Subscriber__r.DeveloperName IN :subscribersName AND Active__c = TRUE
            ORDER BY Subscriber__c, Channel__c, ExecutionOrder__c ASC
        ];
    }
}
