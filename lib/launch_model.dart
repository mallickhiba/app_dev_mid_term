// ignore_for_file: prefer_collection_literals, unnecessary_this, unnecessary_new

class Launch {
	String? missionName;
	String? missionId;
	List<String>? manufacturers;
	List<String>? payloadIds;
	String? wikipedia;
	String? website;
	String? twitter;
	String? description;

	Launch({this.missionName, this.missionId, this.manufacturers, this.payloadIds, this.wikipedia, this.website, this.twitter, this.description});

	Launch.fromJson(Map<String, dynamic> json) {
		missionName = json['mission_name'];
		missionId = json['mission_id'];
		manufacturers = json['manufacturers'].cast<String>();
		payloadIds = json['payload_ids'].cast<String>();
		wikipedia = json['wikipedia'];
		website = json['website'];
		twitter = json['twitter'];
		description = json['description'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['mission_name'] = this.missionName;
		data['mission_id'] = this.missionId;
		data['manufacturers'] = this.manufacturers;
		data['payload_ids'] = this.payloadIds;
		data['wikipedia'] = this.wikipedia;
		data['website'] = this.website;
		data['twitter'] = this.twitter;
		data['description'] = this.description;
		return data;
	}
}