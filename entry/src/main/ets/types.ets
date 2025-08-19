
export interface IMemoRouteParam {
  id: string
}

export interface IColorItemParams {
  color:Color|string
  onClick:(item:Color|string)=>void
}

export interface ITextDecoratorItem{
  icon: Resource;
  onClick:()=>void;
  active?:boolean;
}
export interface ITextColorItem{
  color: Color|string;
}
export interface ITypingStyleParam{
  textColor?: Color|string;
  fontSize?: number;
  isBold?: boolean;
  isItalic?: boolean;
  isUnderline?: boolean;
}
