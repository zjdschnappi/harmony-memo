import { preferences } from "@kit.ArkData";
import { common } from "@kit.AbilityKit";

export enum StorageNameEnum{
  CALENDAR_EVENT = 'calendar_event'
}

export class StorageUtil {
  preferencesData: preferences.Preferences
  constructor(context:common.UIAbilityContext,name:string) {
    this.preferencesData = preferences.getPreferencesSync(context,{name})
  }

  has(key:string){
    return this.preferencesData.hasSync(key)
  }

  set(key:string,value:preferences.ValueType){
    this.preferencesData.putSync(key,value)
    this.preferencesData.flush()
  }
  get(key:string,defaultData='-1'){
    return this.preferencesData.getSync(key,defaultData)
  }
  delete(key:string){
    this.preferencesData.delete(key)
    this.preferencesData.flush()
  }
  flush(callback?:()=>void){
    this.preferencesData.flush(callback)
  }
}