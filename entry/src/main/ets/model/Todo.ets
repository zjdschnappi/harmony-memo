
export enum PriorityLevel{
  NORMAL = 3,
  MEDIUM = 2,
  HIGH = 1
}

export class LocationModel {
  name: string
  latitude: number;
  longitude: number
  radius:number
  constructor(name:string,latitude:number,longitude:number,radius:number) {
    this.name = name;
    this.latitude = latitude;
    this.longitude = longitude
    this.radius = radius
  }
}

@ObservedV2
export class TodoItemSimpleModel {
  id:string;
  todoId:string;
  @Trace title:string;
  @Trace createdTime:string;
  @Trace modifiedTime:string;
  @Trace isCompleted:boolean;
  @Trace priority?:number|null;
  @Trace dueTime?:string|null;
  @Trace location?:LocationModel;
  @Trace memo?:string
  constructor(id:string,todoId:string,title:string,createdTime:string,modifiedTime:string,isCompleted:boolean,priority?:number|null,dueTime?:string|null,location?:LocationModel,memo?:string) {
    this.id = id;
    this.todoId = todoId;
    this.title = title;
    this.createdTime = createdTime;
    this.modifiedTime = modifiedTime;
    this.priority = priority;
    this.isCompleted = isCompleted;
    this.dueTime = dueTime;
    this.location = location;
    this.memo = memo;
  }

}


export interface  ITodoDbEntityModel {
  todo_id: string
  title: string
  is_completed:number;
  created_time: number;
  modified_time: number;
  priority?:number;
  due_time?:number;
  location_name?:string;
  latitude?:number;
  longitude?:number;
  radius?:number
  memo?:string
}


export interface ITodoListItemModel {
  id: string
  todoId: string
  title: string
  priority:number;
  createdTime: string;
  modifiedTime: string;
  dueTime: string;
  isCompleted:boolean;
  locationName:string
}

export interface ITodoDetailModel {
  todoId: string;
  title: string;
  createdTime: string;
  modifiedTime: string;
  isCompleted: boolean;
  dueTime?: string;
  memo?: string;
  priority: number,
  location?: LocationModel


}

export interface ITodoCreateModel {
  title: string
  dueTime?:string;
  location?:LocationModel
  memo?: string;
}

export interface ITodoUpdateModel {
  todoId: string;
  isCompleted?:boolean
  title: string
  dueTime?:string;
  location?:LocationModel
  memo?: string;
}
