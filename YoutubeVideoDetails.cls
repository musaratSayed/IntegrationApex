global class YoutubeVideoDetails{
    
webservice static void details(String VideoId,String RecordId)
{
    String encKey=Youtube_API_Setting__c.getInstance('Youtube API Key').Value__c;
    System.debug('EncKey = '+encKey);
    String endpt=Youtube_API_Setting__c.getInstance('Youtube Endpoints').Value__c;
    System.debug('Endpt: '+endpt);
    endpt = endpt.replace('{VIDEO_ID}', VideoId);
    endpt=endpt.replace('{API_KEY}', encKey);
    System.debug('Endpt: '+endpt);
    
    Http http = new Http();
    HttpRequest httpReq = new HttpRequest();
    HttpResponse httpRes = new HttpResponse();
    httpReq.setEndpoint(endpt);
    httpReq.setMethod('GET');
    httpRes=http.send(httpReq);
    System.debug('resp= '+httpRes);
    
    JSONParser j = (JSONParser)JSON.deserialize(httpRes.getBody(), JSONParser.class);
    
    Youtube_Video_Detail__c yv =new Youtube_Video_Detail__c();
    yv.Id=RecordId;
    yv.Number_of_View_Counts__c = j.items[0].statistics.viewCount;
    system.debug('View counts = '+yv.Number_of_View_Counts__c);
    yv.Number_of_Likes__c=j.items[0].statistics.likeCount;
    yv.Number_of_DisLikes__c=j.items[0].statistics.dislikeCount;
    yv.Number_of_Comments__c=j.items[0].statistics.commentCount;
    
    update yv;
    
}

public class JSONParser {
	public String kind;
	public String etag;
	public List<Items> items;
	public PageInfo pageInfo;
}
	public class PageInfo {
		public Integer totalResults;
		public Integer resultsPerPage;
	}

	

	public class Items {
		public String kind;
		public String etag;
		public String id;
		public Statistics statistics;
	}

	public class Statistics {
		public String viewCount;
		public String likeCount;
		public String dislikeCount;
		public String favoriteCount;
		public String commentCount;
	}

	
	

}