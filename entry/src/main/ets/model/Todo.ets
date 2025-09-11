
export class LocationModel {
  name: string
  latitude: string;
  longitude: string
  constructor(name:string,latitude:string,longitude:string) {
    this.name = name;
    this.latitude = latitude;
    this.longitude = longitude
  }
}

@ObservedV2
export class TodoItemSimpleModel {
  id:string;
  @Trace title:string;
  @Trace createdTime:string;
  @Trace modifiedTime:string;
  @Trace isCompleted:boolean;
  @Trace dueTime?:string|null;
  @Trace location?:LocationModel;
  @Trace memo?:string
  constructor(id:string,title:string,createdTime:string,modifiedTime:string,isCompleted:boolean,dueTime?:string|null,location?:LocationModel,memo?:string) {
    this.id = id;
    this.title = title;
    this.createdTime = createdTime;
    this.modifiedTime = modifiedTime;
    this.isCompleted = isCompleted;
    this.dueTime = dueTime;
    this.location = location;
    this.memo = memo;
  }

}